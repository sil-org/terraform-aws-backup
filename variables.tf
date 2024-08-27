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
  description = "The arn's of the source databases"
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
  description = "The arn's of the source databases"
  type        = list(string)
  default     = ["BACKUP_JOB_STARTED", "BACKUP_JOB_COMPLETED", "BACKUP_JOB_FAILED", "RESTORE_JOB_COMPLETED"]
}

variable "sns_topic_arn" {
  description = "The SNS topic to use for notifications. Leave blank to create a topic named backup-vault-events."
  type        = string
  default     = ""
}
