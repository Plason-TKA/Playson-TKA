provider "aws" {
  region = var.region
  profile = var.profile

  default_tags {
    tags = {
      Env         = var.env
      Service     = "none"
      Created_by  = "TF"
      Team        = "SRE"
    }
  }
}

terraform {
  backend "s3" {}
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
output "alb_security_group_id" {
  value = aws_security_group.alb.id
}