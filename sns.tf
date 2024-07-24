/*########################################################
Rejected Request SNS Topic

########################################################*/
resource "aws_sns_topic" "rejected_requests" {
  name = "${replace(var.project-name, " ", "_")}-Rejected_Requests"
}

resource "aws_sns_topic_subscription" "notify-admin" {
  for_each  = toset(var.admin-email)
  topic_arn = aws_sns_topic.rejected_requests.arn
  protocol  = "email"
  endpoint  = each.key
}
