output "webserver_key_pair" {
  value     = module.key_pair.private_key_openssh
  sensitive = true
}

output "webserver_public_ip" {
  value = module.webserver_ec2.public_ip
}

#######################################################################
#echo "$(terraform output -raw webserver_key_pair)" > webserver_key.pem
#sudo chmod 600 webserver_key.pem  
#ssh -i webserver_key.pem ec2-user@"$(terraform output -raw webserver_public_ip)"