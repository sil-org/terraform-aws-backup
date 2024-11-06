locals {
  # Define key resource types that support cold storage
  supported_resource_types = [
    "cloudformation",
    "dynamodb",
    "ec2",
    "elasticfilesystem",
    "timestream",
    "backup"
  ]

  # Determine the SNS topic ARN to use
  sns_topic_arn = var.sns_topic_arn == "" ? aws_sns_topic.bkup_sns_topic[0].arn : var.sns_topic_arn

  # Identify resources that don't support cold storage
  cold_storage_unsupported_resources = var.enable_cold_storage_check ? [
    for arn in var.source_arns : arn
    if !can(contains(local.supported_resource_types, split(":", arn)[2]))
  ] : []

  # Error message for resources that don't support cold storage
  cold_storage_error_message = (
    var.enable_cold_storage_check &&
    var.cold_storage_after != null &&
    length(local.cold_storage_unsupported_resources) > 0
  ) ? "Error: cold storage is not supported for the following resources: ${join(", ", local.cold_storage_unsupported_resources)}." : null
}

# Validation resource to check if cold storage is enabled for unsupported resources
check "cold_storage_validation" {
  assert {
    condition = (
      !var.enable_cold_storage_check ||
      var.cold_storage_after == null ||
      length(local.cold_storage_unsupported_resources) == 0
    )
    error_message = (
      var.enable_cold_storage_check &&
      var.cold_storage_after != null &&
      length(local.cold_storage_unsupported_resources) > 0
    ) ? "Error: Cold storage is enabled and configured, but the following resources do not support it: ${join(", ", local.cold_storage_unsupported_resources)}. Please review your configuration." : "Cold storage configuration is valid."
  }
}

# Validation to ensure delete_after is at least 90 days more than cold_storage_after
check "lifecycle_validation" {
  assert {
    condition     = var.cold_storage_after == null || var.delete_after == null || (var.delete_after - var.cold_storage_after) >= 90
    error_message = "Error: delete_after must be at least 90 days more than cold_storage_after"
  }
}
# Encryption key for the Backup Vault
resource "aws_kms_key" "bkup_key" {
  description = "${var.app_name}-${var.app_env} backup vault key"

  tags = {
    app_name = var.app_name
    app_env  = var.app_env
  }
}

# Create the Backup vault
resource "aws_backup_vault" "bkup_vault" {
  name        = "${var.app_name}-${var.app_env}-db-backup-vault"
  kms_key_arn = aws_kms_key.bkup_key.arn

  tags = {
    app_name = var.app_name
    app_env  = var.app_env
  }
}

# Create the Backup plan
resource "aws_backup_plan" "bkup_plan" {
  name = "${var.app_name}-${var.app_env}-db-backup-plan"

  rule {
    rule_name         = "${var.app_name}-${var.app_env}-db-backup-rule"
    target_vault_name = aws_backup_vault.bkup_vault.name
    schedule          = var.backup_schedule
    completion_window = 120 # 2 hours (in minutes)

    lifecycle {
      cold_storage_after = var.cold_storage_after
      delete_after       = var.delete_after
    }
  }

  tags = {
    app_name = var.app_name
    app_env  = var.app_env
  }
}

# Select objects to be backed up
resource "aws_backup_selection" "bkup_selection" {
  name         = "${var.app_name}-${var.app_env}-db-backup-selection"
  plan_id      = aws_backup_plan.bkup_plan.id
  iam_role_arn = aws_iam_role.bkup_role.arn
  resources    = var.source_arns
}

# Create the IAM role for backups
resource "aws_iam_role" "bkup_role" {
  name = "${var.app_name}-${var.app_env}-db-backup-role"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = ["sts:AssumeRole"]
          Effect = "allow"
          Principal = {
            Service = ["backup.amazonaws.com"]
          }
        }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "bkup_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.bkup_role.name
}

# Create notifications
resource "aws_sns_topic" "bkup_sns_topic" {
  count = var.sns_topic_arn == "" ? 1 : 0
  name  = var.sns_topic_name
}

data "aws_iam_policy_document" "bkup_sns_policy" {
  statement {
    actions = [
      "SNS:Publish",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    resources = [
      local.sns_topic_arn,
    ]

    sid = "__default_statement_ID"
  }
}

resource "aws_sns_topic_policy" "bkup_sns_topic_policy" {
  arn    = local.sns_topic_arn
  policy = data.aws_iam_policy_document.bkup_sns_policy.json
}

resource "aws_backup_vault_notifications" "bkup_vault_notifications" {
  backup_vault_name   = aws_backup_vault.bkup_vault.name
  sns_topic_arn       = local.sns_topic_arn
  backup_vault_events = var.notification_events
}

resource "aws_sns_topic_subscription" "this" {
  count = var.sns_email_subscription == "" ? 0 : 1

  topic_arn = local.sns_topic_arn
  protocol  = "email"
  endpoint  = var.sns_email_subscription
}
