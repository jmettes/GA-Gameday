# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

module "stack_a" {
  source = "./stack"
  team   = "team-a"
}

module "stack_b" {
  source = "./stack"
  team   = "team-b"
}

resource "aws_instance" "dashboard" {
  ami               = "ami-950b62af"
  instance_type     = "t2.micro"
  availability_zone = "ap-southeast-2a"
  user_data         = "${file("dashboard.sh")}"
  security_groups   = ["${aws_security_group.default.name}"]
  key_name          = "chaos"

  tags {
    Name = "gameday dashboard"
  }
}

resource "aws_security_group" "default" {
  name        = "gameday_sg-dashboard"
  description = "allow http gameday"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}