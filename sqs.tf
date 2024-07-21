/*########################################################
User Submit Queue

########################################################*/
resource "aws_sqs_queue" "user_submit" {
  name_prefix = replace(replace("${var.project-name}_API_Stage", " ", "_"), "-", "_")

  // Max time lambda can run is 15 minutes
  visibility_timeout_seconds = 900
}