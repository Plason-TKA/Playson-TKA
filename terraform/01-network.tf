module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.4.0"

  name = "${var.name}-${var.env}"

  cidr = var.cidr
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway
  enable_vpn_gateway = false

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.name}-${var.env}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.name}-${var.env}" = "shared"
  }
  
  tags = { InfraComponent = "network" }
}
