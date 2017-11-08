# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

module "stack_a" {
  source      = "./stack"
  team = "team-a"
}

module "stack_b" {
  source      = "./stack"
  team = "team-b"
}
