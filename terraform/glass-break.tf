
data "aws_iam_policy" "AdminAccess" {
  name     = "AdministratorAccess"
}

data "aws_iam_policy_document" "assume_role_document" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
      "sts:SetSourceIdentity"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::<Account-id>:user/<user-name>"]
    }
  }
}


resource "aws_iam_role" "<name>" {
  name                = "<Name>"
  assume_role_policy  = data.aws_iam_policy_document.assume_role_document.json
  managed_policy_arns = [data.aws_iam_policy.AdminAccess.arn]
  tags                = {
    created-by        = "Nayan-Rajani"
    creation-date     = "28/12/22"
  }
}