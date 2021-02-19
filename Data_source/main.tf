terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "working" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpcs" "my_vpcs" {}

data "aws_vpc" "dev_vpc" {
  tags = {
    Name = "Dev"
  }
}


### outputs list of all AZs
output "data_aws_availability_zones" {
  value = data.aws_availability_zones.working.names
}
### outputs first AZ
output "data_aws_availability_zone_1" {
  value = data.aws_availability_zones.working.names[0]
}


### outputs current caller's account_id
output "data_aws_caller_identity" {
  value = data.aws_caller_identity.current.account_id
}


### outputs current region name
output "data_aws_region_name" {
  value = data.aws_region.current.name
}
### outputs current region description
output "data_aws_region_description" {
  value = data.aws_region.current.description
}


### outputs current region VPCs ids
output "aws_vpcs" {
  value = data.aws_vpcs.my_vpcs.ids
}


### outputs Dev VPC id
output "data_aws_dev_vpc_id" {
  value = data.aws_vpc.dev_vpc.id
}
### outputs Dev VPC CIDR block
output "data_aws_dev_vpc_cidr-block" {
  value = data.aws_vpc.dev_vpc.cidr_block
}


### create subnet in VPC
resource "aws_subnet" "dev_subnet_1" {
  cidr_block = "172.41.1.0/24"
  vpc_id = data.aws_vpc.dev_vpc.id
  availability_zone = data.aws_availability_zones.working.names[2]
  tags = {
    Name = "Dev subnet-1 in AZ ${data.aws_availability_zones.working.names[2]}"
    Account = "Dev subnet-1 in Account ${data.aws_caller_identity.current.account_id}"
    Region = data.aws_region.current.name
  }
}
resource "aws_subnet" "dev_subnet_2" {
  cidr_block = "172.41.2.0/24"
  vpc_id = data.aws_vpc.dev_vpc.id
  availability_zone = data.aws_availability_zones.working.names[2]
  tags = {
    Name = "Dev subnet-2 in AZ ${data.aws_availability_zones.working.names[2]}"
    Account = "Dev subnet-2 in Account ${data.aws_caller_identity.current.account_id}"
    Region = data.aws_region.current.name
  }
}
resource "aws_subnet" "dev_subnet_3" {
  cidr_block = "172.41.3.0/24"
  vpc_id = data.aws_vpc.dev_vpc.id
  availability_zone = data.aws_availability_zones.working.names[1]
  tags = {
    Name = "Dev subnet-3 in AZ ${data.aws_availability_zones.working.names[1]}"
    Account = "Dev subnet-3 in Account ${data.aws_caller_identity.current.account_id}"
    Region = data.aws_region.current.name
  }
}