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
### resource that is not associated with any specific resource. Does nothing - used for debugging and else
resource "null_resource" "command0" {}

### LOCAL-EXEC
resource "null_resource" "command1" {
  ### 'provisioner "local-exec"' can be defined in any resource, but the command will be executed on local machine
  ### execute command with specified interpreter e.g. PowerShell - !!! should be installed in OS
  provisioner "local-exec" {
    command = "echo Terraform START: $(Get-Date) > log.txt"
    interpreter = ["PowerShell", "-Command"]
  }
}

resource "null_resource" "command2" {
  provisioner "local-exec" {
    command = "ping google.com >> log.txt"
    interpreter = ["PowerShell", "-Command"]
  }
  depends_on = [null_resource.command1]
}
### execute command with python interpreter
### !!! should be installed in OS
resource "null_resource" "command3" {
  provisioner "local-exec" {
    command = "print('Hello World')"
    interpreter = ["python", "-c"]
  }
}
### execute command with using environment variables (not working this way under Windows)
resource "null_resource" "command4" {
  provisioner "local-exec" {
    command = "echo $N1, $N2 $N3 >> greetings.txt"
    environment = {
      N1 = "Aloha!"
      N2 = "Coniciva!"
      N3 = "Nihao!"
    }
  }
}

### REMOTE-EXEC
resource "aws_instance" "web1" {
  ami = "..."
  instance_type = "..."

  provisioner "remote-exec" {
    ### 'inline' - contains a list of command strings, executed in the order they are provided.
    ### Cannot be provided with 'script' or 'scripts'
    inline = [
      "puppet apply",
      "consul join ${aws_instance.web1.private_ip}",
    ]
  }
}


### FILE provisioner
resource "aws_instance" "web2" {
  ami = "..."
  instance_type = "..."

  # Copies the myapp.conf file to /etc/myapp.conf
  provisioner "file" {
    source      = "conf/myapp.conf"
    destination = "/etc/myapp.conf"
  }

  # Copies the string in content into /tmp/file.log
  provisioner "file" {
    content     = "ami used: ${self.ami}"
    destination = "/tmp/file.log"
  }

  # Copies the configs.d folder to /etc/configs.d
  provisioner "file" {
    source      = "conf/configs.d"
    destination = "/etc"
  }

  # Copies all files and folders in apps/app1 to D:/IIS/webapp1
  provisioner "file" {
    source      = "apps/app1/"
    destination = "D:/IIS/webapp1"
  }

}

