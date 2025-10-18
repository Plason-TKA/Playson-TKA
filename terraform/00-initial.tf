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