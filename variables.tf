/*
 * Required variables
 */
variable "app_name" {
  description = "Short app name used in the name of managed resources"
  type        = string
}

variable "app_env" {
  description = "Environment name used in the name of managed resources, e.g. prod, stg"
  type        = string
}

variable "source_arns" {
  description = "Resource identifiers in 'ARN' format (https://docs.aws.amazon.com/IAM/latest/UserGuide/reference-arns.html)"
  type        = list(string)
}


/*
 * Optional variables
 */

variable "backup_schedule" {
  description = "Backup schedule in AWS Cloudwatch Event Bridge format, e.g.\"cron(11 1 * * ? *)\""
  default     = "cron(11 1 * * ? *)" # Every day at 01:11 UTC
}

variable "notification_events" {
  description = "An array of events that indicate the status of jobs to back up resources to the backup vault."
  type        = list(string)
  default     = ["BACKUP_JOB_STARTED", "BACKUP_JOB_COMPLETED", "BACKUP_JOB_FAILED", "RESTORE_JOB_COMPLETED"]
}

variable "sns_topic_arn" {
  description = "The SNS topic to use for notifications. Leave blank to create a topic."
  type        = string
  default     = ""
}

variable "sns_topic_name" {
  description = "The SNS topic name to create if sns_topic_arn is empty"
  type        = string
  default     = "backup-vault-events"
}

variable "sns_email_subscription" {
  description = "Optional: email address to receive SNS events"
  type        = string
  default     = ""
}

variable "cold_storage_after" {
  description = "Number of days after which the backup is moved to cold storage"
  type        = number
  default     = 7
}

variable "delete_after" {
  description = "Number of days after which the backup is deleted"
  type        = number
  default     = 100
}