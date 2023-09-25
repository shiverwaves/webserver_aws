# project vars
variable "project" {}

# aws vars
variable "AWS_REGION" {
    type = string
    description = "TF_VAR_AWS_REGION environment variable set from tf_rm_st_create.sh"
}
variable "AWS_BUCKET_NAME" {
    type = string
    description = "TF_VAR_AWS_BUCKET_NAME environment variable set from tf_rm_st_create.sh"
}
variable "AWS_TABLE_NAME" {
    type = string
    description = "TF_VAR_AWS_TABLE_NAME environment variable set from tf_rm_st_create.sh"
}

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