
variable "region" {
  description = "Current region name"
  type = string
  default     = "eu-central-1"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "allowed_http_ports" {
  type = list(number)
  default = [80, 443]
}

variable "protocols" {
  type = map(string)
  default = {
    TCP   = "tcp"
    UDP   = "udp"
    HTTP  = "http"
    ALL   = "-1"
  }
}

variable "enable_detailed_monitoring" {
  type = bool
  default = true
}

variable "latest_ami_search_values" {
  type = map(string)
  default = {
    AMAZON_LINUX_2 = "amzn2-ami-hvm-2.0.*-x86_64-gp2"
    UBUNTU_20 = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    WINDOWS_SERVER_2019 = "Windows_Server-2019-English-Full-Base-*"
  }
}