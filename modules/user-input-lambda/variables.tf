variable "aws-region" {
  description = "AWS Rrgion code to deploy the resources in"
  type        = string
}

variable "resource-prefix" {
  description = "Prefix to be added to all resources"
  type        = string
}

variable "source_code_zip_path" {
  description = "Path to the source code zip of the lambda function"
  type        = string
}

variable "lambda" {
  description = "Map of lambda function configurations"
  type        = map(string)
}
