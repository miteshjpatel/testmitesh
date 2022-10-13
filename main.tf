/// Testing GitHub update with push and pull just update

terraform {

  backend "s3"{
    bucket = "terraform-state-bucket-i802797"
    key = "tf-state"
    region = "us-east-1"
  }

  required_providers {
    aws = {
       source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "i802797-east-2"
  region  = "us-east-2"
}

resource "aws_s3_bucket" "terraform_course" {
  bucket = "terrafrom-course-bucket"
  acl    = "private"
}

resource "aws_default_vpc" "i802797-defaultS" {
  
}

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-2a"
  tags = {
    Terraform = "true"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-2b"
  tags = {
    Terraform = "true"
  }
}

resource "aws_security_group" "i802797_web" {
  name        = "i802797_web"  
  description = " Allow standard http and https ports inbound and everything outbound"

  ingress = [ {
    cidr_blocks      = [ "0.0.0.0/0" ]
    description      = "value"
    from_port        = 80
    ipv6_cidr_blocks = [ ]
    prefix_list_ids  = [ ]
    protocol         = "tcp"
    security_groups  = [  ]
    self             = false
    to_port          = 80
  },
  {
 cidr_blocks      = [ "0.0.0.0/0" ]
    description      = "value"
    from_port        = 443
    ipv6_cidr_blocks = [ ]
    prefix_list_ids  = [ ]
    protocol         = "tcp"
    security_groups  = [  ]
    self             = false
    to_port          = 443
  } ]

  egress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "value"
    from_port = 0
    ipv6_cidr_blocks = [ ]
    prefix_list_ids = [  ]
    protocol = "-1"
    security_groups = [  ]
    self = false
    to_port = 0
  } ]
  
  tags = {
    Terraform : "true",
    Owner : "i802797"
  }
}
 /* resource "aws_instance" "app_server" {
   count = 2

   ami                    = "ami-0ed34781dc2ec3964"
   instance_type          = "t2.nano"
   vpc_security_group_ids = [aws_security_group.i802797_web.id]

  tags = {
    Name = var.instance_name,
    Terrafrom : "true",
    Owner : "i802797"
  }
} 


resource "aws_eip_association" "app_server" {
  instance_id = aws_instance.app_server.0.id
  allocation_id = aws_eip.app_server.id
  
} */

resource "aws_eip" "app_server" {
  tags = {
    Terrafrom = "true",
    Owner     = "i802797"
  }
}

resource "aws_elb" "app_server" {
  name            = "app-server"
  # instances       = aws_instance.app_server[*].id 
  subnets         = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  security_groups = [aws_security_group.i802797_web.id]
  
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags = {
    Terraform  = "true"
    Owner      = "i802797"
  }
}


resource "aws_launch_template" "app_server" {
  name_prefix   = "app-server"
  # image_id      = "ami-0ed34781dc2ec3964" impage id in us-east-1
  image_id      = "ami-04fba448246555019"   //impage id in us-east-2
  instance_type = "t2.micro"
  
  tags = {
    "Name" = "bitnami-nginx"
  }
}

resource "aws_autoscaling_group" "app_server" {
  availability_zones = ["us-east-2a"]
  # vpc_zone_identifier = [aws_default_subnet.default_az1]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.app_server.id
    version = "$Latest"
  }

  tag  {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_attachment" "app_server" {
  autoscaling_group_name = aws_autoscaling_group.app_server.id
  elb                    = aws_elb.app_server.id
}
