# automation-project-1
This is a personal DevOps Project on AWS using following technologies:

- Terraform
- Ansible
- Jenkins
- Docker
- Grafana
- Maven
- Sonarqube

### Requirements

- Terraform v1.7.3
- Terraform aws provider version "5.35.0"
- AWS account
- public private keys ind the main project directory: `ssh-keygen -q -b 4096 -t rsa -C 'kotys-terraform-ssh-key' -N '' -f "kotys-ssh-key"`   use the same key file name for the variable in terrafrom.tfvars




### To-do

- bootstrap bash script for tfstate s3 bucket & dynamo db and tf iam role 
- make the script idempotent
- Configure Remote backend in S3 & State lock in DynamoDB
- assume role in provider block



### Status
I am currently working on this project. It is not yet completed. 

- VPC, subnets,  IGW, NATGW, security groups, route tables, NACLs are created
- 


## Bootstrap Script Usage:

Configure the default AWS CLI profile or create a new one, before running the script:

```
aws configure --profile <new-profile-name>

``` 


