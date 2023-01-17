## Module overview
This module creates the daily and weekly backup plan based on the flags (enable or disable) defined via account submission request

## Input variables
| Input Variable  | Description  | Default value | Variable type |
| :------------ |:--------------- | :----- | :----- |
| backup_plan_name | AWS backup plan name |  | string |
| Backup_Rule_Name | AWS backup rule name |  | string |
| backup_role_arn | AWS backup role arn that can be assumed by AWS backup service |  | string |
| backup_vault_name | AWS backup vault name to store the backups |  | string |
| selection_tags_keys | Tags to identify resources to be backed up  |  | list(string) |
| backup_schedule_parameter_name | AWS backup schedule |  | string |
| backup_retention_days_parameter_name | Retention period for the backed up resources |  | string |
| window_start | Time (in minutes) within which backup needs to start | 60 | number |
| window_completion | Duration for AWS backup jobs to complete | 780 | number |
| copy_backups_to_dr | Copy backups to DR region | false | bool |
| secondary_vault_arn | AWS DR region backup vault arn - applicable only for prod accounts | "" | string |

## Output values
| Output Variable  | Description  |
| :------------ |:--------------- |
|  |  |

# cron job
- https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html