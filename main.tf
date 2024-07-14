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
  source = "./modules/lambda"

  aws-region  = var.aws-region
  prefix      = var.project_name
  name        = "user-input-lambda"
  description = "Lambda Function Used to server user input"

  source_code_zip_path = data.archive_file.lambda_function-user_input.output_path

  lambda-config = {
    handler        = "main.lambda_handler"
    runtime        = "python3.12"
    architecture   = "arm64"
    execution_role = var.lambda_function-user_input-execution_role
  }
}

resource "aws_lambda_permission" "submit_post" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.user_input_lambda.lambda_function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws-region}:${data.aws_caller_identity.current.account_id}:*/*/*"
}


/*########################################################
API Gateway

########################################################*/
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-API"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = replace(replace("${var.project_name}_API_Stage", " ", "_"), "-", "_")
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.main-api_gateway.arn
    format = jsonencode({
      requestId               = "$context.requestId",
      ip                      = "$context.identity.sourceIp",
      requestTime             = "$context.requestTime",
      httpMethod              = "$context.httpMethod",
      status                  = "$context.status",
      protocol                = "$context.protocol",
      integrationErrorMessage = "$context.integrationErrorMessage",
      errorMessage            = "$context.error.message"
    })
  }
}

resource "aws_apigatewayv2_deployment" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  description = "${var.project_name}-API-Deployment"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_route.submit_post
  ]
}


/*########################################################
API Gateway Log

########################################################*/
resource "aws_cloudwatch_log_group" "main-api_gateway" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.main.id}"
  retention_in_days = 7
}

resource "aws_api_gateway_account" "main-api_gateway" {
  cloudwatch_role_arn = aws_iam_role.main-api_gateway.arn
}

resource "aws_iam_role" "main-api_gateway" {
  name = replace(replace("${var.project_name}-Main-API-Gateway-Role", " ", "_"), "-", "_")
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "cloudwatch-logs"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "logs:GetLogEvents",
            "logs:FilterLogEvents",
          ],
          Resource = ["*"]
        }
      ]
    })
  }
}


/*########################################################
API Gateway Resource

Path: /submit_post

########################################################*/
resource "aws_apigatewayv2_route" "submit_post" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /submit_post"
  target    = "integrations/${aws_apigatewayv2_integration.submit_post.id}"
}

resource "aws_apigatewayv2_integration" "submit_post" {
  api_id               = aws_apigatewayv2_api.main.id
  passthrough_behavior = "WHEN_NO_MATCH"
  integration_type     = "AWS_PROXY"
  integration_method   = "POST"
  integration_uri      = module.user_input_lambda.lambda_function.invoke_arn
}
