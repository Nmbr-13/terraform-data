#################################################################
# Provision Highly available Web-server in any Region Default VPC
# Create:
# 	- Security Group for Web-server
# 	- Launch configuration with Auto AMI lookup
# 	- AutoScaling group using 2 AZs
# 	- ELB in 2 AZs
#################################################################


terraform {
	required_providers {
		aws = {
		  source  = "hashicorp/aws"
		  version = "~> 3.0"
		}
	}
}
provider "aws" {
	### to use variable: var.<variable_name>
	region = var.region
}

data "aws_ami" "latest_amazon_linux2" {
	owners = ["amazon"]
	most_recent = true
	filter {
		name = "name"
		values = [var.latest_ami_search_values.AMAZON_LINUX_2]
	}
}

data aws_region "current" {}
data aws_availability_zones "current_available" {}

resource "aws_security_group" "http_sg"{
	name = "Web-Server-SG"
	dynamic "ingress"{
		for_each = var.allowed_http_ports

		content{
			from_port = ingress.value
			### if variable is map - var.<var_name>.<key>
			protocol = var.protocols.TCP
			to_port = ingress.value
			cidr_blocks = ["0.0.0.0/0"]
		}
	}
	egress{
		from_port = 0
		protocol = var.protocols.ALL
		to_port = 0
		cidr_blocks = ["0.0.0.0/0"]
	}
	### local - local variable
	### to use local-var tags + uncommon tag - 'merge'
	tags = merge({Name = "Web-Server-SG"}, local.common_tags)
}

resource "aws_eip" "my_static_ip" {
	instance = aws_instance.my_server.id
	tags = merge({Name = "Web-Server-Static-IP"}, local.common_tags)
}

resource "aws_instance" "my_server" {
	ami = data.aws_ami.latest_amazon_linux2.id
	instance_type = var.instance_type
	vpc_security_group_ids = [aws_security_group.http_sg.id]
	### bool value also can be defined as variable
	monitoring = var.enable_detailed_monitoring

	tags = merge({ Name = "Server built by Terraform" }, local.common_tags)
}