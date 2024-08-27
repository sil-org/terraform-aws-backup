
module "minimal" {
  source      = "../"
  app_name    = "minimal"
  app_env     = "test"
  source_arns = ["arn:aws:rds:us-east-1:123456789012:db:my-db"]
}

module "full" {
  source              = "../"
  app_name            = "full"
  app_env             = "test"
  source_arns         = ["arn:aws:rds:us-east-1:123456789012:db:my-db"]
  backup_schedule     = "cron(11 1 * * ? *)"
  notification_events = ["BACKUP_JOB_STARTED", "BACKUP_JOB_COMPLETED", "BACKUP_JOB_FAILED", "RESTORE_JOB_COMPLETED"]
  sns_topic_name      = "backup-vault-events-prod"
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      version = "~> 4.0"
      source  = "hashicorp/aws"
    }
  }
}
