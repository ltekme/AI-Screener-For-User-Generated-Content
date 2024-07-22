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
  description = "Lambda Function used to validate user input"

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
            Effect   = "Allow",
            Action   = "sqs:SendMessage",
            Resource = ["${aws_sqs_queue.user_submit.arn}"]
          }
        ]
      }
    }
  ]
  
  additional-environment-variables = {
    "SQS_QUEUE_URL" = "${aws_sqs_queue.user_submit.url}"
  }
}
