# Terraform Module for AWS Backup

This module is used to create scheduled backups of AWS RDS databases. It was previously published at https://github.com/silinternational/terraform-modules/aws/backup/rds.

## Resources Managed

* KMS Encryption key
* Backup Vault
* Backup Plan
* Backup Selection
* IAM Role and Policy
* SNS Topic and Policy
* Backup Vault Notifications

This module is published in [Terraform Registry](https://registry.terraform.io/modules/silinternational/backup/aws/latest).

## Example Usage

```hcl
module "backup_rds" {
  source = "silinternational/backup-rds/aws"
  app_name = var.app_name
  app_env = var.app_env
  source_arns = ["arn:aws:rds:us-east-1:123456789012:db:my-db"]
  backup_cron_schedule = "11 1 * * ? *"
  notification_events = ["BACKUP_JOB_STARTED", "BACKUP_JOB_COMPLETED", "BACKUP_JOB_FAILED", "RESTORE_JOB_COMPLETED"]
}
```
