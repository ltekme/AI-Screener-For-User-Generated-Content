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
variable "lambda_function-user_request-execution_role" {
  description = "The ARN of the IAM role that the user_request lambda function will assume"
  type        = string
  default     = null
}

variable "lambda_function-content_flagger-execution_role" {
  description = "The ARN of the IAM role that the content_flagger lambda function will assume"
  type        = string
  default     = null
}

variable "lambda_function-request_writer-execution_role" {
  description = "The ARN of the IAM role that the request_writer lambda function will assume"
  type        = string
  default     = null
}

variable "lambda_function-request_reader-execution_role" {
  description = "The ARN of the IAM role that the request_writer lambda function will assume"
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

variable "bedrock-model-id" {
  description = "The ID of the Bedrock model to use for content flagging"
  type        = string
  default     = "anthropic.claude-3-haiku-20240307-v1:0"
}

variable "admin-email" {
  description = "The email address of the admin to notify when a request is denied"
  type        = list(string)
  default     = []
}
