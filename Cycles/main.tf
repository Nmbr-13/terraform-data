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

data "aws_ami" "latest_amazon_linux2" {
	owners = ["amazon"]
	most_recent = true
	filter {
		name = "name"
		values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
	}
}

variable "aws_users" {
  description = "List of IAM users to create"
  default = ["BruceBanner", "PeterParker", "RidRichards", "MattMurdock", "StephenStrange", "ClarkKent"]
}

#COUNT-CYCLE-EXAMPLES----------------------------------------------------------------------------------

resource "aws_iam_user" "users" {
  ### for each next element the 'count.index' will be i+1
  count = length(var.aws_users)
  name = element(var.aws_users, count.index)
}



resource "aws_instance" "servers" {
  count = 3
  ami = data.aws_ami.latest_amazon_linux2.id
  instance_type = "t2.micro"
  tags = {
    Name = "server #${count.index+1}"
  }
}

#END-COUNT-CYCLE-EXAMPLES-----------------------------------------------------------------------------
#FOR-IF-CYCLE-EXAMPLES--------------------------------------------------------------------------------

output "created_iam_users_ids" {
  value = aws_iam_user.users[*].id
}

output "created_iam_users_custom" {
  value = [
  for user in aws_iam_user.users:
  "Username ${user.name} has ARN: ${user.arn}"
  ]
}

output "created_iam_users_custom2" {
  value = {
  for user in aws_iam_user.users:
  user.unique_id => user.id ### outputs map-like string - "AIDA4BML4STW...." = "BruceBanner"
  }
}

output "created_iam_users_custom3" {
  value = [
  for x in aws_iam_user.users:
  x.name
  if length(x.name) <= 11
  ]
}

output "servers_ids_with_public_ips" {
  value = {
    for server in aws_instance.servers:
        server.id => server.public_ip ### outputs map-like string - "i-086......" = "172.164.227.38"
  }
}