/*########################################################
User Submit Queue

########################################################*/
resource "aws_sqs_queue" "user_submit" {
  name_prefix = replace(replace("${var.project-name}_API_Stage", " ", "_"), "-", "_")

  // Max time lambda can run is 15 minutes
  visibility_timeout_seconds = 900
}

resource "aws_lambda_event_source_mapping" "user_submit" {
  event_source_arn = aws_sqs_queue.user_submit.arn
  function_name    = module.user_input_lambda.lambda_function.arn
}
