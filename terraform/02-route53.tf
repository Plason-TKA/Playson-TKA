module "zone" {
  source = "terraform-aws-modules/route53/aws"
  version = "6.1.0"

  name    = "playson-tka.int"
  comment = "Private zone for playson take home assignment"

  vpc = {
    one = {
      vpc_id     = module.vpc.vpc_id
      vpc_region = var.region
    }
  }
  tags = {
    InfraComponent     = "InfraComponent"
  }
}