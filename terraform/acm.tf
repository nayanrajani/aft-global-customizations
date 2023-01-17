data "aws_caller_identity" "current" {}

data "aws_caller_identity" "aft_management_account" {
  provider = aws.aft_management_account
}

resource "aws_acm_certificate" "mm_acm_example_public" {
  domain_name               = "example.com"
  subject_alternative_names = ["*.example.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      Name = "example.com"
    }
  )
}

resource "aws_acm_certificate" "mm_acm_m_devsecops_public" {
  domain_name               = "example1.com"
  subject_alternative_names = ["*.example1.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      Name = "example1.com"
    }
  )
}

resource "aws_ssm_parameter" "mm_ssm_acm_example_public" {
  provider  = aws.aft_management_account_admin
  name      = "/mm/acm/${data.aws_caller_identity.current.account_id}/example_core_domain"
  type      = "StringList"
  value     = join(",", ["CNAME = ${tolist(aws_acm_certificate.mm_acm_example_public.domain_validation_options)[0]["resource_record_name"]}", "CNAME_VALUE = ${tolist(aws_acm_certificate.mm_acm_example_public.domain_validation_options)[0]["resource_record_value"]}"])
  overwrite = true
  depends_on = [
    aws_acm_certificate.mm_acm_m_devsecops_public,
    aws_acm_certificate.mm_acm_example_public
  ]
}



resource "aws_ssm_parameter" "mm_ssm_acm_m_devsecops_public" {
  provider  = aws.aft_management_account_admin
  name      = "/mm/acm/${data.aws_caller_identity.current.account_id}/example_devsecops"
  type      = "StringList"
  value     = join(",", ["CNAME = ${tolist(aws_acm_certificate.mm_acm_m_devsecops_public.domain_validation_options)[0]["resource_record_name"]}", "CNAME_VALUE = ${tolist(aws_acm_certificate.mm_acm_m_devsecops_public.domain_validation_options)[0]["resource_record_value"]}"])
  #value     = tolist(aws_acm_certificate.mm_acm_m_devsecops_public.domain_validation_options)[0]["resource_record_name"]
  overwrite = true
  depends_on = [
    aws_acm_certificate.mm_acm_m_devsecops_public,
    aws_acm_certificate.mm_acm_example_public
  ]
}


