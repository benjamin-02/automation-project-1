# Initialization of the aws provider

provider "aws" {
  shared_config_files      = ["$HOME/.aws/config"]
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile                  = "personal"
  region                   = var.region
}
