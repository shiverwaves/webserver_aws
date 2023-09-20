provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  # https://aws.amazon.com/about-aws/global-infrastructure/regions_az/
  azs = slice(data.aws_availability_zones.available.names, 0, var.azs_count)

}

module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git"

  name = "${var.project}-vpc"
  cidr = var.vpc_cidr

  azs = local.azs
  # https://developer.hashicorp.com/terraform/language/expressions/for
  # https://developer.hashicorp.com/terraform/language/functions/cidrsubnet
  public_subnets = [for i, v in local.azs : cidrsubnet(var.vpc_cidr, var.newbits, i)]
}

module "webserver_sg" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group/"

  name   = "${var.project}-webserver-sg"
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = var.sg_ingress_cidr
  ingress_rules       = var.sg_rules
}

module "key_pair" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-key-pair"

  key_name           = "${var.project}-ssh-key"
  create_private_key = true
}

data "aws_ami" "os" {
  most_recent = true
  filter {
    name   = "name"
    values = [var.ami_name]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "webserver_ec2" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/"

  name                        = "${var.project}-webserver-ec2"
  ami                         = data.aws_ami.os.id
  instance_type               = var.instance_type
  key_name                    = module.key_pair.key_pair_name
  vpc_security_group_ids      = [module.webserver_sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = var.public_ip
}
