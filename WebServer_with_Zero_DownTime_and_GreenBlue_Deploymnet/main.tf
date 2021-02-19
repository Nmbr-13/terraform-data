#################################################################
# Provision Highly available Web-server in any Region Default VPC
# Create:
# 	- Security Group for Web-server
# 	- Launch configuration with Auto AMI lookup
# 	- AutoScaling group using 2 AZs
# 	- ELB in 2 AZs
#################################################################

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

data "aws_availability_zones" "azs" {}

data "aws_ami" "latest_amazon_linux2" {
  owners = ["137112412989"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

### returns default VPC data
//data "aws_vpc" "default" {
//  default = true
//}

### returns default VPC subnets
//data "aws_subnet_ids" "subnets" {
//  vpc_id = data.aws_vpc.default.id
//}

### converts to set of default VPC subnets
//data "aws_subnet" "default_subnet" {
//  for_each = data.aws_subnet_ids.subnets.ids
//  id = each.key
//}

### returns 1st default VPC subnet
//data aws_subnet "default_subnet_1" {
//  id = [for s in data.aws_subnet.default_subnet : s.id][0]
//}
### returns 2nd default VPC subnet
//data aws_subnet "default_subnet_2" {
//  id = [for s in data.aws_subnet.default_subnet : s.id][1]
//}

### prints 1st default VPC subnet ID
//output "default_subnet_1" {
//	value = data.aws_subnet.default_subnet_1.id
//}
### prints 2nd default VPC subnet ID
//output "default_vpc_subnets" {
//	value = data.aws_subnet_ids.subnets.ids
//}

###AWS SG###############################################
resource "aws_security_group" "http_dynamic_web"{
	name = "Dynamic-http-SG"
	description = "Opens access to several ports"
	vpc_id = aws_default_vpc.default.id

	dynamic "ingress"{
		for_each = ["80","443"]  ## Cycle through list.

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
		Name = "Dynamic-SG"
		Owner = "Nmb13"
	}
}

###AWS LC##############################################
resource "aws_launch_configuration" "web_server" {
	### 1. New LC should have a unique name => use 'name-prefix' instead of 'name'
	name_prefix = "WebServer-HA-LC-"
	image_id = data.aws_ami.latest_amazon_linux2.id
	instance_type = "t2.micro"
	security_groups = [aws_security_group.http_dynamic_web.id]
	user_data = file("user_data.sh")

	lifecycle {
		create_before_destroy = true
	}
}

###AWS ASG#############################################
resource "aws_autoscaling_group" "as_group" {
	### 1. 'aws_autoscaling_group' now depends on aws_launch_configuration
	### 2. If LC configuration-code is updated the new one will be created
	name                      	= "ASG-${aws_launch_configuration.web_server.name}"
	max_size                  	= 3
  	min_size                  	= 2
  	launch_configuration      	= aws_launch_configuration.web_server.name
  	min_elb_capacity 			= 2 # number of LB health-checks
	### 'health_check_type' accepts 'ELB' or 'EC2'
  	health_check_type 			= "ELB"
	vpc_zone_identifier 		= [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]

	### 1. with 'target_group_arns' - you can drop 'aws_autoscaling_attachment' resource
	### 2. with 'target_group_arns' parameter + lifecycle.create_before_destroy -
	#      old ASG will be destroyed ONLY after new one starts working - Zero DownTime
	target_group_arns 			= [aws_lb_target_group.lb_target_group.arn]
	### DO NOT USE 'load_balancer' parameter with ALB or NLB!!!
	dynamic "tag" {
		for_each = {
			Name 	= "WebServer-in-ASG"
			Owner 	= "Srg Nmb13"
			TAGKEY 	= "TAGVALUE"
		}
		content {
			key 				= tag.key
			propagate_at_launch = true
			value 				= tag.value
		}
	}

	lifecycle {
		create_before_destroy = true
	}

}

resource "aws_autoscaling_policy" "web_policy_up" {
  name = "web_policy_up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.as_group.name
}
### attach autoscaling group to LB target group
//resource "aws_autoscaling_attachment" "lb_autoscaling" {
//	alb_target_group_arn = aws_lb_target_group.lb_target_group.arn
//	autoscaling_group_name = aws_autoscaling_group.as_group.id
//
//	lifecycle {
//		create_before_destroy = true
//	}
//}

resource "aws_default_vpc" "default" {
	tags = {
    	Name = "default"
	}
}

resource "aws_default_subnet" "default_az1" {
	availability_zone = data.aws_availability_zones.azs.names[0]
	tags = {
		Name = "default_az1"
	}
}
resource "aws_default_subnet" "default_az2" {
	availability_zone = data.aws_availability_zones.azs.names[1]
	tags = {
		Name = "default_az2"
	}
}

### Network LoadBalancer
//resource "aws_lb" "web_lb" {
//	name 								= "WebServer-HA-ELB"
//	internal 							= false
//	load_balancer_type 					= "network"
//	enable_cross_zone_load_balancing 	= true
//	subnets = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
//
//	tags = {
//		Name = "WebServer-HA-NLB"
//	}
//}

### Application LoadBalancer
resource "aws_lb" "web_lb" {
	name            = "WebServer-HA-ELB"
	load_balancer_type = "application"
	subnets 		= [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
	security_groups = [aws_security_group.http_dynamic_web.id]
	internal        = false
	idle_timeout    = 60
	enable_cross_zone_load_balancing = true
	tags = {
		Name = "WebServer-HA-ELB"
	}
}

resource "aws_lb_target_group" "lb_target_group" {
	name     	= "WebServer-HA-LB-target-group"
	port     	= 80
//	protocol 	= "TCP" ### for NLB only
	protocol 	= "HTTP"
	vpc_id   	= aws_default_vpc.default.id
	tags = {
		Name = "WebServer-HA-LB-target-group"
	}
//	stickiness {
//    type            = "lb_cookie"
//    cookie_duration = 1800
//    enabled         = true
//	}
	health_check { ### this config works only with ALB!
		healthy_threshold   = 3
		unhealthy_threshold = 5
		timeout             = 5
		interval            = 10
		path                = "/"
		port                = 80
		matcher = "200"
	}
}

resource "aws_lb_listener" "lb_listener" {
	load_balancer_arn 	= aws_lb.web_lb.arn
  	port              	= 80
//  	protocol          = "TCP" ### only for NLB
	protocol 			= "HTTP"
  	default_action {
    	target_group_arn = aws_lb_target_group.lb_target_group.arn
    	type             = "forward"
  	}
}

### returns domain_url of working LoadBalancer
output "web_lb_url" {
	value = aws_lb.web_lb.dns_name
}

