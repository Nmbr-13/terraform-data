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

data "aws_ami" "latest_ubuntu" {
  owners = ["099720109477"] ###
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

output "latest_ubuntu_ami_id" {
  value = data.aws_ami.latest_ubuntu.id
}
output "latest_ubuntu_ami_name" {
  value = data.aws_ami.latest_ubuntu.name
}
output "latest_ubuntu_ami_creation-date" {
  value = data.aws_ami.latest_ubuntu.creation_date
}



data "aws_ami" "latest_amazon_linux2" {
  owners = ["137112412989"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}
output "latest_amazon_linux2_ami_id" {
  value = data.aws_ami.latest_amazon_linux2.id
}
output "latest_amazon_linux2_ami_name" {
  value = data.aws_ami.latest_amazon_linux2.name
}
output "latest_amazon_linux2_ami_creation-date" {
  value = data.aws_ami.latest_amazon_linux2.creation_date
}


data "aws_ami" "latest_windows" {
  owners = ["801119661308"]
  most_recent = true
  filter {
    name = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}
output "latest_windows_ami_id" {
  value = data.aws_ami.latest_windows.id
}
output "latest_windows_ami_name" {
  value = data.aws_ami.latest_windows.name
}
output "latest_windows_ami_creation-date" {
  value = data.aws_ami.latest_windows.creation_date
}