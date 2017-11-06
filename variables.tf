variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "ap-southeast-2"
}

# ubuntu-trusty-14.04 (x64)
variable "aws_amis" {
  default = {
    "us-east-1" = "ami-5f709f34"
    "us-west-2" = "ami-7f675e4f"
    "ap-southeast-2" = "ami-950b62af"
  }
}

variable "availability_zones" {
  default     = "ap-southeast-2a,ap-southeast-2b"
  description = "List of availability zones, use AWS CLI to find your "
}

variable "key_name" {
  description = "key pair name"
  default = "chaos"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "2"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "1"
}