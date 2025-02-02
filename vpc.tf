variable vpc_cidr_block {}
variable private_subnet_cidr_blocks {}
variable public_subnet_cidr_blocks {}
variable intra_subnets_cidr_blocks {}

data "aws_availability_zones" "available" {}

module "myapp-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.16.0"

  name = "myapp-vpc"
  cidr = var.vpc_cidr_block
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets = var.public_subnet_cidr_blocks
  azs = data.aws_availability_zones.available.names 
  intra_subnets = var.intra_subnets_cidr_blocks
  
  enable_nat_gateway = true

  tags = {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/elb" = 1 
  }

  private_subnet_tags = {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/internal-elb" = 1 
  }

}