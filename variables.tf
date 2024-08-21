/*########################################################
Terrafrom AWS Project Settings

########################################################*/
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
Lambda Function Execution Roles

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

variable "lambda_function-sns_control-execution_role" {
  description = "The ARN of the IAM role that the sns_control lambda function will assume"
  type        = string
  default     = null
}

variable "lambda_function-flagger_control-execution_role" {
  description = "The ARN of the IAM role that the flagger_control lambda function will assume"
  type        = string
  default     = null
}


/*########################################################
APi Gateway Settings

########################################################*/
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


/*########################################################
Content Flagger Settings

########################################################*/
variable "bedrock-model-id" {
  description = "The ID of the Bedrock model to use for content flagging"
  type        = string
  default     = "foundation-model/anthropic.claude-3-haiku-20240307-v1:0"
}

variable "bypass-flagger" {
  description = "Weather to bypass content flagger"
  type        = bool
  default     = false
}

variable "always-flag" {
  description = "Weather to always flag content"
  type        = bool
  default     = false
}


/*########################################################
Web Interface Settings

########################################################*/
variable "admin-email" {
  description = "The email address of the admin to notify when a request is rejected. Can be changed in the web interface"
  type        = list(string)
  default     = []
}

variable "use-cloudfront" {
  description = "Weather to use cloudfront or not"
  type        = bool
  default     = true
}
