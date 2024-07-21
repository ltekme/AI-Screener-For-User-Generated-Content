/*########################################################
User Input Lambda Module

########################################################*/
data "archive_file" "lambda_function-user_input" {
  // Zip file of the lambda function
  type        = "zip"
  source_dir  = "${path.module}/user_input-code"
  output_path = "${path.module}/user_input-code.zip"
}

module "user_input_lambda" {
  // Lambda Function Defination
  source = "./modules/lambda"

  aws-region  = var.aws-region
  prefix      = var.project-name
  name        = "user-input-lambda"
  description = "Lambda Function Used to server user input"

  source_code_zip_path = data.archive_file.lambda_function-user_input.output_path

  lambda-config = {
    handler        = "main.lambda_handler"
    runtime        = "python3.12"
    architecture   = "arm64"
    execution_role = var.lambda_function-user_input-execution_role
  }

  additional-permissions = [
    {
      name = "sqs-permission"
      policy = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow",
            Action = [
              "sqs:ReceiveMessage",
              "sqs:DeleteMessage",
              "sqs:GetQueueAttributes",
            ],
            Resource = ["${aws_sqs_queue.user_submit.arn}"]
          }
        ]
      }
    }
  ]
}

resource "aws_lambda_permission" "submit_post" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.user_input_lambda.lambda_function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws-region}:${data.aws_caller_identity.current.account_id}:*/*/*"
}
