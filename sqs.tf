/*########################################################
User Request Queue

########################################################*/
resource "aws_sqs_queue" "user_request" {
  name_prefix = replace(replace("${var.project-name}-User_Request", " ", "_"), "-", "_")

  visibility_timeout_seconds = 900
  message_retention_seconds  = (1 * 24 * 60 * 60) // 1 day
}

resource "aws_lambda_event_source_mapping" "user_request-lambda" {
  event_source_arn = aws_sqs_queue.user_request.arn
  function_name    = module.content_flagger_lambda.lambda_function.arn
  batch_size       = 1

  scaling_config {
    maximum_concurrency = 2
  }
}


/*########################################################
Request Writer SQS Queue

########################################################*/
resource "aws_sqs_queue" "request-writer" {
  name_prefix = replace(replace("${var.project-name}-Writer", " ", "_"), "-", "_")

  visibility_timeout_seconds = 900
  message_retention_seconds  = (1 * 24 * 60 * 60) // 1 day
}

resource "aws_lambda_event_source_mapping" "request-writer-lambda" {
  event_source_arn = aws_sqs_queue.request-writer.arn
  function_name    = module.request_writer_lambda.lambda_function.arn
  batch_size       = 1

  scaling_config {
    maximum_concurrency = 2
  }
}
