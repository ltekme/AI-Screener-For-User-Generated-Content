/*########################################################
Terraform Requiements

########################################################*/
terraform {
  required_version = ">= 1.9.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.57.0"
    }
  }
}


/*########################################################
AWS Terraform Provider

########################################################*/
provider "aws" {
  default_tags {
    tags = {
      Created_by = "Terrafrom"
      Project    = var.project-name
    }
  }
  region = var.aws-region
}
data "aws_caller_identity" "current" {}


/*########################################################
Extra Null Resource

########################################################*/
resource "null_resource" "always_trigger" {
  triggers = {
    always_run = "${timestamp()}"
  }
}
