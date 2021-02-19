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

terraform {
  ### With this setting the .tfstate file will be held remotely in S3 bucket!
  backend "s3" {
    bucket = "nmb13-study-project"
    ### the directory in S3 bucket where this project .tfstate file will be held
    key = "dev/network/terraform.tfstate"
    region = "eu-west-1"
  }
}
#=================================================================================
variable "vpc_cidr" {
  default = "10.16.0.0/16"
}
#=================================================================================
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Main VPC"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

#=================================================================================
output "main_vpc_id" {
  value = aws_vpc.main.id
}
output "main_vpc_cidr" {
  value = var.vpc_cidr
}