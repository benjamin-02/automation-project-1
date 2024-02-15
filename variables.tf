variable "region" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "public_subnet1_cidr_block" {
  type = string
}

variable "public_subnet2_cidr_block" {
  type = string
}

variable "private_subnet1_cidr_block" {
  type = string
}

variable "private_subnet2_cidr_block" {
  type = string
}

variable "jenkins_port" {
  type = number
}

variable "sonarqube_port" {
  type = number
}

variable "grafana_port" {
  type = number
}

variable "web_app_port" {
  type = number
}

variable "ssh_keyfile_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "aws_image_id" {
  type = string
}