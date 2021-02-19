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

resource "aws_instance" "webserver_1" {
  ami = data.aws_ami.latest_amazon_linux2.id
  ### value depends on condition
  instance_type = lookup(var.instance_types, var.env)
  tags = {
    Name = "${var.env}-server"
    Owner = "Nmb13"
  }
}

resource "aws_security_group" "http_dynamic_web"{
	name = "Dynamic-http-SG"
	description = "Opens access to several ports"

	dynamic "ingress"{
		for_each = lookup(var.allowed_ports_list, var.env)
		content{
			from_port = ingress.value //dynamic content
			protocol = "tcp"
			to_port = ingress.value
			cidr_blocks = ["0.0.0.0/0"]
		}
	}
	egress{
		from_port = 0
		protocol = "-1"
		to_port = 0
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags={
		Name = "Dynamic-SG-by-Terraform"
		Owner = "Nmb13"
	}
}

output "environment" {
  value = var.env
}
output "instance_type" {
  value = lookup(var.instance_types, var.env)
}
output "allowed_ports" {
  value = lookup(var.allowed_ports_list, var.env)
}
