# project vars
variable "project" {}

# aws vars
variable "region" {}

# vpc vars
variable "vpc_cidr" {}
# subnet vars
variable "azs_count" {}
variable "newbits" {}

# security group vars
variable "sg_ingress_cidr" {}
variable "sg_rules" {}

# instance vars
variable "ami_name" {}
variable "instance_type" {}
variable "public_ip" {}