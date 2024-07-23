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
              "${aws_sqs_queue.accepted-request.arn}",
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
              "${aws_sns_topic.denied_requests.arn}"
            ]
          }
        ]
      }
    }
  ]
  additional-environment-variables = {
    "ACCEPTED_SQS_QUEUE_URL" = "${aws_sqs_queue.accepted-request.url}",
    "REJECTED_SNS_TOPIC_ARN" = "${aws_sns_topic.denied_requests.arn}",
    "MODEL_ID"               = "${var.bedrock-model-id}"
  }
}
