variable "project_name" {
  description = "The name of the project(can only contain letters, numbers, and hyphens)"
  type        = string
  default     = "AI Content Screener"
}

variable "aws-region" {
  description = "AWS Rrgion code to deploy the resources in"
  type        = string
  default     = "us-east-1"
}

variable "lambda_function-user_input-execution_role" {
  description = "The ARN of the IAM role that the lambda function will assume"
  type        = string
  default     = null
}