# Terraform Module for AWS Backup

This module is used to create scheduled backups of AWS resources. It was previously published at https://github.com/sil-org/terraform-modules/aws/backup/rds.

## Resources Managed

* KMS Encryption key
* Backup Vault
* Backup Plan
* Backup Selection
* IAM Role and Policy
* SNS Topic and Policy
* Backup Vault Notifications

This module is published in [Terraform Registry](https://registry.terraform.io/modules/sil-org/backup/aws/latest).

## Example Usage

```hcl
module "backup_rds" {
  source              = "sil-org/backup/aws"
  app_name            = var.app_name
  app_env             = var.app_env
  source_arns         = ["arn:aws:rds:us-east-1:123456789012:db:my-db"]
  backup_schedule     = "cron(11 1 * * ? *)"
  notification_events = ["BACKUP_JOB_STARTED", "BACKUP_JOB_COMPLETED", "BACKUP_JOB_FAILED", "RESTORE_JOB_COMPLETED"]
}
```
