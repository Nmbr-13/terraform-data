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


resource "aws_security_group" "http_dynamic_web"{
	name = "Dynamic-http-SG"
	description = "Opens access to several ports"

	dynamic "ingress"{ // 'dynamic' key-word to define dynamic block
		for_each = ["80","443"]  //cycle through list.
								//List can be imported from external Variables-file
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
