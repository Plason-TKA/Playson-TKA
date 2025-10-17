# Init
variable "profile" {
  description = "AWS profile name for the provision account"
  default     = "profile_development_tka"
}

variable "region" {
  description = "AWS Region where to provision VPC Network"
  default     = "us-east-1"
}

variable "env" {
  description = "Env name"
}

# Shared
variable "name" {
  description = "Name for AWS created services"
  default = "test"
}

# Network 
variable "cidr" {
  description = "The IPv4 CIDR block for the VPC"  
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}