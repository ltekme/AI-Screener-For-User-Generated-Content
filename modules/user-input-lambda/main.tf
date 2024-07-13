/*########################################################
locals

########################################################*/
locals {
  prefix = lower(replace(replace(var.resource-prefix, " ", "-"), "_", "-"))
  create_lambda_role = var.lambda.execution_role == null ? true : false
  lambda_role_arn = var.lambda.execution_role != null ? var.lambda.execution_role : aws_iam_role.lambda_function-user_input[0].arn
  lambda_function_name = "${local.prefix}-user-input-handler"
}
data "aws_caller_identity" "current" {}


/*########################################################
Lambda Function Permissions

###############################################lambda_function-user_input#########*/
resource "aws_iam_role" "lambda_function-user_input" {
  // Role For User Input Lambda Function
  count = "${local.create_lambda_role == true ? 1 : 0}"
  name = lower("${local.prefix}-user-input-lambda-role")
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  // Permit CloudWatch Logs
  inline_policy {
    name = "user-input-lambda-policy-cloudwatch-logs"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          Resource = "arn:aws:logs:${var.aws-region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_function_name}:*"
        }
      ]
    })
  }
  
}


/*########################################################
Lambda Function

########################################################*/
resource "aws_lambda_function" "user_input" {
  // User Input Lambda Function
  function_name = local.lambda_function_name
  description   = "Lambda Function Used to server user input"

  filename         = var.source_code_zip_path
  source_code_hash = filebase64sha256(var.source_code_zip_path)

  handler       = var.lambda.handler
  runtime       = var.lambda.runtime
  architectures = [var.lambda.architectures]

  role = local.lambda_role_arn
}
