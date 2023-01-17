# Use role from AFT management account
provider "aws" {
  alias  = "aft_management_account"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "aft_management_account_admin"
  region = "ap-south-1"
  assume_role {
    role_arn = "arn:aws:iam::${data.aws_caller_identity.aft_management_account.account_id}:role/AWSAFTExecution"
  }
}
