/*########################################################
AWS DynamoDB Table For Posts

Attributes:
  - year_created(PK-String): The year the post was created
  - datetime_created(RK-String): The datetime the post was created

The Attributes are best for cases where posts are not created fequently, e.g. 3-4 posts per month,
The Hash Key can be adjusted to include the month created for more frequent posts e.g. 20-30 posts per month
It is a balance between the number of partition key and range key per partition key, 
and should be adjusted according to each use case.

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name = "${replace(var.project-name, " ", "_")}-Posts"

  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1

  hash_key  = "year_created"
  range_key = "datetime_created"

  attribute {
    name = "year_created"
    type = "S"
  }

  attribute {
    name = "datetime_created"
    type = "S"
  }
}

########################################################*/
