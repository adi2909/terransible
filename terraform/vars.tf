variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" { default = "us-west-2" }
variable "ec2_service_role" {}
variable "vpc_id"  {}
variable "cidr" {}
variable "public_subnet_ids"  {}
variable "private_subnet_ids" {}
variable "system_tag" {}
variable "instance_keyname"    {}

