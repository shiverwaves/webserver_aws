# project vars
project = "webserver-test"

# aws vars
region = "us-east-1"

# vpc vars
vpc_cidr = "172.16.0.0/16"
# subnet vars
azs_count = 1
newbits   = 8

# security group vars
sg_ingress_cidr = ["0.0.0.0/0"]
sg_rules        = ["ssh-tcp", "http-80-tcp"]

# instance vars
ami_name      = "RHEL-9*"
instance_type = "t2.micro"
public_ip     = true