variable "env" {
  type = string
  description = "Environment where infrastructure should be created"
  default     = "DEV"
}

variable "env_types" {
  type = map(string)
  default = {
    TEST    = "TEST"
    DEV     = "DEV"
    PROD    = "PROD"
  }
}

variable "default_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "dev_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "prod_instance_type" {
  type    = string
  default = "t2.large"
}