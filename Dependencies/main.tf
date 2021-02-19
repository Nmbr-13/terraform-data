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

resource "aws_instance" "server_web" {
  ami = "ami-0a6dc7529cd559185"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.http_dynamic_web.id] // this is also dependency =>
                                                                    // SG will be created first!!!

  tags = {
    Name = "Server-Web"
  }

  depends_on = [aws_instance.server_db, aws_instance.server_app] // will be created last!
}

resource "aws_instance" "server_app" {
  ami = "ami-0a6dc7529cd559185"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.http_dynamic_web.id]

  tags = {
    Name = "Server-Application"
  }

  depends_on = [aws_instance.server_db] // 'server_app' depends on 'server_db' =>
                                        // 'server_db' instance will be created first
                                        // The destroy order also goes according to dependencies!
}

resource "aws_instance" "server_db" {
  ami = "ami-0a6dc7529cd559185"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.http_dynamic_web.id]

  tags = {
    Name = "Server-DataBase"
  }
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
  }
}
