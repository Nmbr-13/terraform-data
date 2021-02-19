terraform {
  ### With this setting the .tfstate file will be held remotely in S3 bucket!
  backend "s3" {
    bucket = "nmb13-study-project"
    ### the directory in S3 bucket where this project .tfstate file will be held
    key = "dev/servers/terraform.tfstate"
    region = "eu-west-1"
  }
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
#====================================================================================
data "terraform_remote_state" "network" {
  backend = "s3"
  ### the same settings as in terraform.backend block
  config = {
    bucket = "nmb13-study-project"
    key = "dev/network/terraform.tfstate"
    region = "eu-west-1"
  }
}
#====================================================================================
resource "aws_security_group" "servers_http_access"{
	name = "Dynamic-http-SG"
	description = "Opens access to several ports"
	### takes network-project 'main_vpc_id' output
	vpc_id = data.terraform_remote_state.network.outputs.main_vpc_id

	dynamic "ingress"{
		for_each = ["80","443"]
		content{
			from_port = ingress.value //dynamic content
			protocol = "tcp"
			to_port = ingress.value
			### takes 'network' project - 'main_vpc_cidr' output
			cidr_blocks = [data.terraform_remote_state.network.outputs.main_vpc_cidr]
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
#====================================================================================
### will output all data from .tfstate of 'network' project
output "network_details" {
  value = data.terraform_remote_state.network
}

### this output will be able to be used in 'network' project
output "security_group_id" {
	value = aws_security_group.servers_http_access.id
}