##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  version = "~>2.0"
  profile = "anna-prod"
  region     = var.region
}

##################################################################################
# DATA
##################################################################################

data "aws_availability_zones" "available" {}

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.44.0"

  name = "anna1"

  cidr = var.cidr_block
  azs = slice(data.aws_availability_zones.available.names,0,var.subnet_count)
  private_subnets = var.private_subnets
  public_subnets = var.public_subnets

  enable_nat_gateway = false

  create_database_subnet_group = false

  
  tags = {
    Environment = "Production"
    Team = "Network"
  }
}






