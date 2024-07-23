/*########################################################
Rejected Request SNS Topic

########################################################*/
resource "aws_sns_topic" "denied_requests" {
  name = "${replace(var.project-name, " ", "_")}-Denied_Requests"
}

resource "aws_sns_topic_subscription" "notify-admin" {
  for_each  = toset(var.admin-email)
  topic_arn = aws_sns_topic.denied_requests.arn
  protocol  = "email"
  endpoint  = each.key
}
