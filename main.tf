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
      Project    = var.project_name
    }
  }
  region = var.aws-region
}
data "aws_caller_identity" "current" {}


/*########################################################
User Input Lambda Module

########################################################*/

data "archive_file" "lambda_function-user_input" {
  // Zip file of the lambda function
  type        = "zip"
  source_dir  = "${path.module}/lambda_function-user_input"
  output_path = "${path.module}/lambda_function-user_input.zip"
}

module "user_input_lambda" {
  // Lambda Function for User Input
  // Abstracted into module
  source = "./modules/user-input-lambda"

  aws-region           = var.aws-region
  resource-prefix      = var.project_name
  source_code_zip_path = data.archive_file.lambda_function-user_input.output_path

  lambda = {
    handler       = "main.handler"
    runtime       = "python3.12"
    architectures = "arm64"
    execution_role = var.lambda_function-user_input-execution_role
  }
}
