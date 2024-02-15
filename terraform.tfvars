region = "eu-central-1"

vpc_cidr_block = "10.0.0.0/16"

public_subnet1_cidr_block = "10.0.0.0/24"
public_subnet2_cidr_block = "10.0.1.0/24"

private_subnet1_cidr_block = "10.0.10.0/24"
private_subnet2_cidr_block = "10.0.11.0/24"

jenkins_port   = 8080
sonarqube_port = 9000
grafana_port   = 3000
web_app_port   = 80

ssh_keyfile_name = "kotys-ssh-key"
instance_type    = "t2.micro"
aws_image_id     = "ami-03614aa887519d781" # Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type