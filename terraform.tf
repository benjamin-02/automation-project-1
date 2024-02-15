terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.35.0"
    }
    
  }

  # backend "s3" {
  #   bucket         	   = "kotys-tf-remote-state-bucket-24"
  #   key              	 = "prod/terraform.tfstate"
  #   region         	   = "eu-central-1"
  #   encrypt        	   = true              # already enabled with bootstrap script??? 
  #   dynamodb_table     = "tf-lock-table"
  # }
}