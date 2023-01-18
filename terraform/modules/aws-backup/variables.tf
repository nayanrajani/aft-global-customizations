variable "backup_plan_name" {
  type = string
}

variable "Backup_Rule_Name" {
  type = string
}

variable "backup_role_arn" {
  type = string
}

variable "backup_vault_name" {
  type = string
}

variable "selection_tags_keys" {
  type = list(string)
}

variable "backup_schedule_parameter_name" {
  type = string
}

variable "backup_retention_days_parameter_name" {
  type = string
}

variable "window_start" {
  type    = number
  default = 60
}

variable "window_completion" {
  type    = number
  default = 780
}

variable "copy_backups_to_dr" {
  type    = bool
  default = false
}

variable "secondary_vault_arn" {
  type    = string
  default = ""
}

variable "continous_backup" {
  type    = bool
  default = true
}