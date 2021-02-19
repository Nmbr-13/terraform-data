terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"

//  assume_role {
//    role_arn = "arn:aws:iam:1234567890:role/SomeRole" ### role_arn of another account under that you manage
//    session_name = "TEST_SESSION"
//  }
}

provider "aws" {
  region = "eu-west-1"
  alias = "EU_IRELAND"
}

provider "aws" {
  region = "eu-west-2"
  alias = "EU_GB"
}


#==========================================================

data "aws_ami" "latest_amazon_linux2_default" {
  owners = ["amazon"]
  most_recent = true
  filter {
      name = "name"
      values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

data "aws_ami" "latest_amazon_linux2_ireland" {
  provider = aws.EU_IRELAND
  owners = ["amazon"]
  most_recent = true
  filter {
      name = "name"
      values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

data "aws_ami" "latest_amazon_linux2_gb" {
  provider = aws.EU_GB
  owners = ["amazon"]
  most_recent = true
  filter {
      name = "name"
      values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

#==========================================================

resource "aws_instance" "default_server" {
  ami = data.aws_ami.latest_amazon_linux2_default.id
  instance_type = "t2.micro"
  tags = {
    Name = "default_server"
  }
}

resource "aws_instance" "ireland_server" {
  provider = aws.EU_IRELAND
  ami = data.aws_ami.latest_amazon_linux2_ireland.id
  instance_type = "t2.micro"
  tags = {
    Name = "ireland-server"
  }
}

resource "aws_instance" "gb_server" {
  provider = aws.EU_GB
  ami = data.aws_ami.latest_amazon_linux2_gb.id
  instance_type = "t2.micro"
  tags = {
    Name = "gb-server"
  }
}

#==========================================================

