/*########################################################
User Input Lambda Module

########################################################*/
data "archive_file" "lambda_function-user_request" {
  // Zip file of the lambda function
  type        = "zip"
  source_dir  = "${path.module}/code/user_request"
  output_path = "${path.module}/code/user_request.zip"
}

module "user_request_lambda" {
  // Lambda Function Defination
  source = "./modules/lambda"

  aws-region  = var.aws-region
  prefix      = var.project-name
  name        = "user-request-function"
  description = "Lambda Function used to validate user input"

  source_code_zip_path = data.archive_file.lambda_function-user_request.output_path

  lambda-config = {
    handler        = "main.lambda_handler"
    runtime        = "python3.12"
    architecture   = "arm64"
    execution_role = var.lambda_function-user_request-execution_role
  }

  additional-permissions = [
    {
      name = "sqs-permission"
      policy = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow",
            Action   = ["sqs:SendMessage"],
            Resource = ["${aws_sqs_queue.user_request.arn}"]
          }
        ]
      }
    }
  ]

  additional-environment-variables = {
    "SQS_QUEUE_URL" = "${aws_sqs_queue.user_request.url}"
  }
}


/*########################################################
Content Flagger Lambda Module

########################################################*/
data "archive_file" "lambda_function-content_flagger" {
  // Zip file of the lambda function
  type        = "zip"
  source_dir  = "${path.module}/code/content_flagger"
  output_path = "${path.module}/code/content_flagger.zip"
}

module "content_flagger_lambda" {
  // Lambda Function Defination
  source = "./modules/lambda"

  aws-region  = var.aws-region
  prefix      = var.project-name
  name        = "content-flagging-function"
  description = "Lambda Function used to flag content"

  source_code_zip_path = data.archive_file.lambda_function-content_flagger.output_path

  lambda-config = {
    handler        = "main.lambda_handler"
    runtime        = "python3.12"
    architecture   = "arm64"
    timeout        = 10
    execution_role = var.lambda_function-content_flagger-execution_role
  }

  additional-permissions = [
    {
      name = "sqs-input"
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
            Resource = ["${aws_sqs_queue.user_request.arn}"]
          }
        ]
      }
    },
    {
      name = "sqs-output"
      policy = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow",
            Action = ["sqs:SendMessage"],
            Resource = [
              "${aws_sqs_queue.request-writer.arn}",
            ]
          }
        ]
      }
    },
    {
      name = "bedrock-invoke"
      policy = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow",
            Action = ["bedrock:InvokeModel"],
            Resource = [
              "arn:aws:bedrock:us-east-1::foundation-model/${var.bedrock-model-id}"
            ]
          }
        ]
      }
    },
    {
      name = "publish-sns"
      policy = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow",
            Action = ["sns:Publish"],
            Resource = [
              "${aws_sns_topic.rejected_requests.arn}"
            ]
          }
        ]
      }
    }
  ]
  additional-environment-variables = {
    "WRITER_SQS_QUEUE_URL"   = "${aws_sqs_queue.request-writer.url}",
    "REJECTED_SNS_TOPIC_ARN" = "${aws_sns_topic.rejected_requests.arn}",
    "MODEL_ID"               = "${var.bedrock-model-id}"
  }
}


/*########################################################
DynamoDB Request Writer Lambda Module

########################################################*/
data "archive_file" "lambda_function-request_writer" {
  // Zip file of the lambda function
  type        = "zip"
  source_dir  = "${path.module}/code/request_writer"
  output_path = "${path.module}/code/request_writer.zip"
}

module "request_writer_lambda" {
  // Lambda Function Defination
  source = "./modules/lambda"

  aws-region  = var.aws-region
  prefix      = var.project-name
  name        = "request_writer-function"
  description = "Lambda Function used to write user request to dynamodb tables"

  source_code_zip_path = data.archive_file.lambda_function-request_writer.output_path

  lambda-config = {
    handler        = "main.lambda_handler"
    runtime        = "python3.12"
    architecture   = "arm64"
    execution_role = var.lambda_function-request_writer-execution_role
  }

  additional-permissions = [
    {
      name = "sqs-input"
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
            Resource = [
              "${aws_sqs_queue.request-writer.arn}"
            ]
          }
        ]
      }
    },
    {
      name = "dynamodb-permission"
      policy = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow",
            Action   = ["dynamodb:PutItem"],
            Resource = ["${aws_dynamodb_table.request.arn}"]
          }
        ]
      }
    }
  ]

  additional-environment-variables = {
    "REQUEST_TABLE_NAME" = "${aws_dynamodb_table.request.arn}"
  }
}


/*########################################################
DynamoDB Request Reader

########################################################*/
data "archive_file" "lambda_function-request_reader" {
  // Zip file of the lambda function
  type        = "zip"
  source_dir  = "${path.module}/code/request_reader"
  output_path = "${path.module}/code/request_reader.zip"
}

module "request_reader_lambda" {
  // Lambda Function Defination
  source = "./modules/lambda"

  aws-region  = var.aws-region
  prefix      = var.project-name
  name        = "request_reader-function"
  description = "Lambda Function used to read user request to dynamodb tables"

  source_code_zip_path = data.archive_file.lambda_function-request_reader.output_path

  lambda-config = {
    handler        = "main.lambda_handler"
    runtime        = "python3.12"
    architecture   = "arm64"
    execution_role = var.lambda_function-request_reader-execution_role
  }

  additional-permissions = [
    {
      name = "dynamodb-permission"
      policy = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow",
            Action   = ["dynamodb:Query"],
            Resource = ["${aws_dynamodb_table.request.arn}"]
          }
        ]
      }
    }
  ]

  additional-environment-variables = {
    "REQUEST_TABLE_NAME" = "${aws_dynamodb_table.request.arn}"
  }
}


/*########################################################
SNS Topic Controller API

########################################################*/
data "archive_file" "lambda_function-sns_control" {
  // Zip file of the lambda function
  type        = "zip"
  source_dir  = "${path.module}/code/sns_control"
  output_path = "${path.module}/code/sns_control.zip"
}

module "sns_control_lambda" {
  // Lambda Function Defination
  source = "./modules/lambda"

  aws-region  = var.aws-region
  prefix      = var.project-name
  name        = "sns_control-function"
  description = "Lambda Function used to control sns topic"

  source_code_zip_path = data.archive_file.lambda_function-sns_control.output_path

  lambda-config = {
    handler        = "main.lambda_handler"
    runtime        = "python3.12"
    architecture   = "arm64"
    execution_role = var.lambda_function-sns_control-execution_role
  }

  additional-permissions = [
    {
      name = "sns-control"
      policy = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow",
            Action   = ["sns:Subscribe"],
            Resource = ["${aws_sns_topic.rejected_requests.arn}"]
            Condition = {
              StringEquals = {
                "sns:protocol" = "email"
              }
            }
          },
          {
            Effect   = "Allow",
            Action   = ["sns:Unsubscribe"],
            Resource = ["${aws_sns_topic.rejected_requests.arn}"]
          },
          {
            Effect   = "Allow",
            Action   = ["sns:ListSubscriptionsByTopic"],
            Resource = ["${aws_sns_topic.rejected_requests.arn}"]
          }
        ]
      }
    }
  ]

  additional-environment-variables = {
    "NOTIFY_SNS_TOPIC" = "${aws_sns_topic.rejected_requests.arn}"
  }
}
