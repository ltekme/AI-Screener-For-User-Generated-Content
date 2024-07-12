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