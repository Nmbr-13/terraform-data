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
### SSM Parameter Store
resource aws_ssm_parameter "rds_password" {
  name = "/test/postgresql"
  description = "Master password for Postgres RDS"
  ### 'type' accepts values: 'String', 'StringList', 'SecureString'
  type = "SecureString"
  value = random_string.rds_password.result
}

### get secret from SSM Parameter Store
data aws_ssm_parameter "rds_password" {
  name = aws_ssm_parameter.rds_password.name

  depends_on = [aws_ssm_parameter.rds_password]
}

output "rds_password" {
  value = data.aws_ssm_parameter.rds_password.value
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
  username             = "db_admin"
  password             = data.aws_ssm_parameter.rds_password.value
  ### for MySQL - e.g. - "default.mysql5.7". Groups list - HERE
  parameter_group_name = "default.postgres12"
  ### if false - will save snap shot of DB before deletion
  skip_final_snapshot  = true
  apply_immediately    = true
}