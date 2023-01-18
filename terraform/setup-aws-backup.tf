data "aws_ssm_parameter" "daily_backup_enabled" {
  name = "/aft/account-request/custom-fields/daily_backup_enabled"
}

data "aws_ssm_parameter" "weekly_backup_enabled" {
  name = "/aft/account-request/custom-fields/weekly_backup_enabled"
}

data "aws_ssm_parameter" "monthly_backup_enabled" {
  name = "/aft/account-request/custom-fields/monthly_backup_enabled"
}

data "aws_ssm_parameter" "yearly_backup_enabled" {
  name = "/aft/account-request/custom-fields/yearly_backup_enabled"
}

data "template_file" "backup_policy_template" {
  template = file("templates/backup_policy.json.tpl")
}

resource "aws_kms_key" "mm_backup_vault_kms" {
  description              = "KMS CMK for AWS BACKUP VAULT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  is_enabled               = true
  enable_key_rotation      = true
  key_usage = "ENCRYPT_DECRYPT"
  tags                     = {
    "key-for" = "AWS-BACKUP-VAULT"
  }
}

# Add an alias to the key
resource "aws_kms_alias" "mm_backup_vault_kms_cmk" {
  name          = "alias/mm_cmk_kms"
  target_key_id = aws_kms_key.mm_backup_vault_kms.key_id
}

resource "aws_backup_vault" "backup_vault" {
  name = "mm-backup-vault"
  kms_key_arn = aws_kms_key.mm_backup_vault_kms.arn
}

#enable_continuous_backup = false for yearly backup because
# "With continuous backups, you can restore your AWS Backup-supported resource by rewinding it back to a specific time that you choose, within 1 second of precision (going back a maximum of 35 days). Available for RDS, and S3 resources."

# AND

# "The retention period for continuous backups can be between 1 and 35 days."
# that's why it was not taking 365 days

module "Daily_Backup_Plan" {
  count                                = data.aws_ssm_parameter.daily_backup_enabled.value ? 1 : 0
  source                               = "./modules/aws-backup"
  backup_plan_name                     = "Daily_Backup_Plan"
  Backup_Rule_Name                     = "Daily_Backup_Plan_Rule"
  backup_role_arn                      = aws_iam_role.backup_role.arn
  backup_vault_name                    = aws_backup_vault.backup_vault.name
  selection_tags_keys                  = ["daily-backup"]
  backup_schedule_parameter_name       = "daily_backup_schedule"
  backup_retention_days_parameter_name = "daily_backup_retention"
  continous_backup                     = true
}

module "Weekly_Backup_Plan" {
  count                                = data.aws_ssm_parameter.weekly_backup_enabled.value ? 1 : 0
  source                               = "./modules/aws-backup"
  backup_plan_name                     = "Weekly_Backup_Plan"
  Backup_Rule_Name                     = "Weekly_Backup_Plan_Rule"
  backup_role_arn                      = aws_iam_role.backup_role.arn
  backup_vault_name                    = aws_backup_vault.backup_vault.name
  selection_tags_keys                  = ["weekly-backup"]
  backup_schedule_parameter_name       = "weekly_backup_schedule"
  backup_retention_days_parameter_name = "weekly_backup_retention"
  continous_backup                     = true
}

module "Monthly_Backup_Plan" {
  count                                = data.aws_ssm_parameter.monthly_backup_enabled.value ? 1 : 0
  source                               = "./modules/aws-backup"
  backup_plan_name                     = "Monthly_Backup_Plan"
  Backup_Rule_Name                     = "Monthly_Backup_Plan_Rule"
  backup_role_arn                      = aws_iam_role.backup_role.arn
  backup_vault_name                    = aws_backup_vault.backup_vault.name
  selection_tags_keys                  = ["monthly-backup"]
  backup_schedule_parameter_name       = "monthly_backup_schedule"
  backup_retention_days_parameter_name = "monthly_backup_retention"
  continous_backup                     = true

}

module "Yearly_Backup_Plan" {
  count                                = data.aws_ssm_parameter.yearly_backup_enabled.value ? 1 : 0
  source                               = "./modules/aws-backup"
  backup_plan_name                     = "Yearly_Backup_Plan"
  Backup_Rule_Name                     = "Yearly_Backup_Plan_Rule"
  backup_role_arn                      = aws_iam_role.backup_role.arn
  backup_vault_name                    = aws_backup_vault.backup_vault.name
  selection_tags_keys                  = ["yearly-backup"]
  backup_schedule_parameter_name       = "yearly_backup_schedule"
  backup_retention_days_parameter_name = "yearly_backup_retention"
  continous_backup                     = false

}

resource "aws_iam_role" "backup_role" {
  name               = "backup_role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "backup_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role.name
}

resource "aws_iam_policy" "backup_role_policy" {
  policy = data.template_file.backup_policy_template.rendered
}
resource "aws_iam_role_policy_attachment" "backup_role_policy_ec2_rds" {
  policy_arn = aws_iam_policy.backup_role_policy.arn
  role       = aws_iam_role.backup_role.name
}


# Create backup vault in DR i.e. secondary region
# resource "aws_backup_vault" "dr_backup_vault" {
#   provider = aws.target_account_admin_dr_region
#   count    = length(split("mm-prod-", data.aws_ssm_parameter.account_alias.value)) > 1 ? 1 : 0
#   name     = "secondary_backup_vault"
# }

# copy_backups_to_dr                   = length(split("mm-prod-", data.aws_ssm_parameter.account_alias.value)) > 1 ? true : false
# secondary_vault_arn                  = length(split("mm-prod-", data.aws_ssm_parameter.account_alias.value)) > 1 ? aws_backup_vault.dr_backup_vault[0].arn : null

# copy_backups_to_dr                   = length(split("mm-prod-", data.aws_ssm_parameter.account_alias.value)) > 1 ? true : false
# secondary_vault_arn                  = length(split("mm-prod-", data.aws_ssm_parameter.account_alias.value)) > 1 ? aws_backup_vault.dr_backup_vault[0].arn : null