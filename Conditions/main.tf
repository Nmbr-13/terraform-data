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
  instance_type = var.env==var.env_types.PROD? var.prod_instance_type : var.env==var.env_types.DEV? var.dev_instance_type:var.default_instance_type
}

### making resource creation depending on condition
resource "aws_instance" "webserver_depending_on_condition" {
  ### 'count' - defines the quantity of this resources to create
  count = var.env==var.env_types.TEST? 1:0

  ami = data.aws_ami.latest_amazon_linux2.id
  instance_type = var.default_instance_type
}
