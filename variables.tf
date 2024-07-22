variable "project-name" {
  description = "The name of the project(can only contain letters, numbers, and hyphens)"
  type        = string
  default     = "AI Content Screener"
}

variable "aws-region" {
  description = "AWS Rrgion code to deploy the resources in"
  type        = string
  default     = "us-east-1"
}


/*########################################################
Optional Variable

########################################################*/
variable "lambda_function-user_input-execution_role" {
  description = "The ARN of the IAM role that the lambda function will assume"
  type        = string
  default     = null
}

variable "api_gateway-account-role" {
  description = "The ARN of the IAM role that the API Gateway will assume"
  type        = string
  default     = null
}

variable "api_gateway-enable-logs" {
  description = "Enable CloudWatch Logs for the API Gateway"
  type        = bool
  default     = true
}

variable "api_gateway-route-submit-integration-role-arn" {
  description = "The ARN of the IAM role that the API Gateway will assume for the submit_post route"
  type        = string
  default     = null
}