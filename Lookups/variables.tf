variable "env" {
  type = string
  description = "Environment where infrastructure should be created"
}

variable "env_types" {
  type = map(string)
  default = {
    TEST    = "test"
    DEV     = "dev"
    PROD    = "prod"
  }
}

variable "instance_types" {
  default = {
    prod  = "t2.large"
    dev   = "t2.medium"
    test  = "t2.micro"
  }
}

variable "allowed_ports_list" {
  default = {
    test  = [80, 443, 8080, 8888, 8000]
    dev   = [80, 443, 8080]
    prod  = [80, 443]
  }
}