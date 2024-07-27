# AI-Screener-For-User-Generated-Content

A concept for using bedrock to flag user generated content.

## Usage

In the tests, include bedrock_test.py inside is

## Deploying

As of right now this project cannot be deployed on aws adaedmy lab account due to the lack of amazon bedrock service.

### Deploying on your own account

```sh
terraform init
terrafrom apply -var "admin-email=example@email.com"
```

replace `example@email.com` with your own email.

## References

- SQS Send Messages: [https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/sqs/client/send_message.html#](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/sqs/client/send_message.html#)

- boto3 Invoke Bedrock: [https://docs.aws.amazon.com/code-library/latest/ug/python_3_bedrock-runtime_code_examples.html](https://docs.aws.amazon.com/code-library/latest/ug/python_3_bedrock-runtime_code_examples.html)

- [https://stackoverflow.com/questions/45803824/how-to-debug-issues-with-amazon-sqs-subscription-to-sns](https://stackoverflow.com/questions/45803824/how-to-debug-issues-with-amazon-sqs-subscription-to-sns)

- [https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb/client/put_item.html](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb/client/put_item.html)
