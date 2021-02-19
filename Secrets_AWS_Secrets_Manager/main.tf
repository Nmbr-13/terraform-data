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

variable "trigger" {
  default = "trigger"
}


#EXAMPLE#############################################################################
resource "random_string" "example" {
  length = 8
  special = true
  override_special = "!@#$%&"
}

resource "aws_secretsmanager_secret" "example" {
  name_prefix = "example"
}

resource aws_secretsmanager_secret_version "example_secret" {
  secret_id = aws_secretsmanager_secret.example.id
  secret_string = random_string.example.result
}
#END-EXAMPLE#########################################################################


### non-aws resource
resource random_string "rds_password" {
  ### password's length
  length = 12
  ### include special characters
  special = true
  ### specify special characters (some special chars are not allowed by terraform)
  override_special = "!#$&"
  ### if value of any of keepers is changed - the all 'random_string' resource value will be changed
  #   => works like trigger if changed
  keepers = {
    # 'trigger' - random name
    trigger = var.trigger
  }
}

variable "rds_login" {
  default = "db_admin"
  ### prevents showing variable's value in the 'plan' or 'apply' output
  sensitive = true
}

locals {
  rds_login_password = {
    login = var.rds_login
    password = random_string.rds_password.result
  }
}

### resource contains secret's metadata
resource aws_secretsmanager_secret "rds_password_secret" {
  name_prefix = "postgres_rds_password_secret_"

  provisioner "local-exec" {
     command = "echo Creating aws_secretsmanager_secret 'rds_password_secret'"
  }
}

### resource contains secret's value and version
resource aws_secretsmanager_secret_version "rds_password_secret" {
  secret_id = aws_secretsmanager_secret.rds_password_secret.id
  ### 'jsonencode()' gets map variable and converts it to json-format string
  secret_string = jsonencode(local.rds_login_password)

  provisioner "local-exec" {
     command = "echo Creating aws_secretsmanager_secret_version 'rds_password_secret'"
  }
}

data aws_secretsmanager_secret_version "rds_password_secret" {
  secret_id = aws_secretsmanager_secret.rds_password_secret.id

  depends_on = [aws_secretsmanager_secret_version.rds_password_secret]
}

locals {
  ### 'jsondecode()' gets json-format string and interprets to primary type value
  ### e.g.:jsonencode(<map>)->json_string, jsondecode(json_string)-><map>
  rds_login_secret = jsondecode(data.aws_secretsmanager_secret_version.rds_password_secret.secret_string)["login"]
  rds_password_secret = jsondecode(data.aws_secretsmanager_secret_version.rds_password_secret.secret_string)["password"]
}


### create RDS
resource aws_db_instance "default" {
  identifier           = "prod-rds"
  allocated_storage    = 20
  storage_type         = "gp2"
  ### for MySQL - mysql
  engine               = "postgres"
  ### for MySQL - e.g. - 5.7
  engine_version       = "12.5"
  instance_class       = "db.t2.micro"
  name                 = "my_postgres_db"
  username             = local.rds_login_secret
  password             = local.rds_password_secret
  ### for MySQL - e.g. - "default.mysql5.7". Groups list - HERE
  parameter_group_name = "default.postgres12"
  ### if false - will save snap shot of DB before deletion
  skip_final_snapshot  = true
  apply_immediately    = true
}


output "rds_login" {
  value = local.rds_login_secret
}
output "rds_password" {
  value = local.rds_password_secret
}