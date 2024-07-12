/*########################################################
locals

########################################################*/
locals {
  prefix = lower(replace(replace(var.resource-prefix, " ", "-"), "_", "-"))
}


/*########################################################
Lambda Function Permissions

########################################################*/
resource "aws_iam_role" "lambda_function-user_input" {
  // Role For User Input Lambda Function
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
          Resource = "arn:aws:logs:${var.aws-region}:${data.aws_caller_identity.account_id}:log-group:/aws/lambda/${local.user-input-lambda.name}:*"
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
  function_name = "${local.prefix}-user-input-handler"
  description   = "Lambda Function Used to server user input"

  filename         = var.source_code_zip_path
  source_code_hash = filebase64sha256(var.source_code_zip_path)

  handler       = var.lambda.handler
  runtime       = var.lambda.runtime
  architectures = [var.lambda.architectures]

  role = aws_iam_role.lambda_function-user_input.arn
}
