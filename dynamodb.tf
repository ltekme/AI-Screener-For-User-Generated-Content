/*########################################################
AWS DynamoDB Table For Requests

Attributes:
  - flagged(PK-S): True if the content is flagged
  - datetime_created(RK-S): The datetime the post was created

########################################################*/
resource "aws_dynamodb_table" "request" {
  name = "${replace(var.project-name, " ", "_")}-UserRequest"

  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1

  hash_key  = "flagged"
  range_key = "timestamp"

  attribute {
    name = "flagged"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}
