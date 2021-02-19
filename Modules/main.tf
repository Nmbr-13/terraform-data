terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "vpc_default" {
  ### path to required module folder
  ### modules can be placed anywhere, not only in project folder
  source = "git@github.com:Nmbr-13/terraform-modules.git//modules/aws_network"
}

module "vpc_dev" {
  source = "git@github.com:Nmbr-13/terraform-modules.git//modules/aws_network"
  ### variables defined in module are like 'arguments' of function
  ### without overriding variables values module will work with default values!!!
  env = "dev"
  vpc_cidr = "10.100.0.0/16"
  public_subnet_cidrs = ["10.100.1.0/24", "10.100.2.0/24"]
  private_subnet_cidrs = []
}

module "vpc_prod" {
  source = "git@github.com:Nmbr-13/terraform-modules.git//modules/aws_network"
  env = "prod"
  vpc_cidr = "10.111.0.0/16"
  public_subnet_cidrs = ["10.111.1.0/24", "10.111.2.0/24", "10.111.3.0/24"]
  private_subnet_cidrs = ["10.111.11.0/24", "10.111.22.0/24", "10.111.33.0/24"]
}

module "vpc_test" {
  source = "git@github.com:Nmbr-13/terraform-modules.git//modules/aws_network"
  ### variables defined in module are like 'arguments' of function
  ### without overriding variables values module will work with default values!!!
  env = "test"
  vpc_cidr = "10.222.0.0/16"
  public_subnet_cidrs = ["10.222.1.0/24", "10.222.2.0/24"]
  private_subnet_cidrs = ["10.222.11.0/24", "10.222.22.0/24"]
}
#=================================================================================

output "prod_public_subnet_ids" {
  value = module.vpc_prod.public_subnets_ids
}

output "prod_private_subnet_ids" {
  value = module.vpc_prod.private_subnets_ids
}