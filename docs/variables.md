# Variable Defination

## Terrafrom AWS Project Variables

| Variable Name | type   | required | default             |
| ------------- | ------ | -------- | ------------------- |
| project-name  | string | yes      | AI Content Screener |
| aws-region    | string | yes      | us-east-1           |

- `project-name`
  
   The name of the project. All resources created by this project will have a tag `Project` with the value of this variable's value.
  
   Resource with naming support will have the variable's valus as it's prefix. This applies to most resources, some may not have it.
  
- `aws-region`
  
  The region in which all resources will be deployed.

## Lambda Function Execution Roles

The variables in this section can be left as default if the iam role used allow the creation of aws iam role. The the role variable is set to null, terrafrom will create the role needed.

The roles is assumed by `Service: lambda.amazonaws.com`.

| Variable Name                                  | type   | required | default |
| ---------------------------------------------- | ------ | -------- | ------- |
| lambda_function-user_request-execution_role    | string | yes      | null    |
| lambda_function-content_flagger-execution_role | string | yes      | null    |
| lambda_function-request_writer-execution_role  | string | yes      | null    |
| lambda_function-request_reader-execution_role  | string | yes      | null    |
| lambda_function-sns_control-execution_role     | string | yes      | null    |
| lambda_function-flagger_control-execution_role | string | yes      | null    |

- lambda_function-user_request-execution_role
  
  Permission Required:
  
  - sqs:SendMessage

- lambda_function-content_flagger-execution_role

  Permission Required:
  - sqs:ReceiveMessage
  - sqs:DeleteMessage
  - sqs:GetQueueAttributes
  - sqs:SendMessage
  - bedrock:InvokeModel
  - sns:Publish
  - ssm:GetParameter
  
  `bedrock:InvokeModel` not required if variable `bypass-flagger` or `always-flag` is set to true

- lambda_function-request_writer-execution_role  

  Permission Required:

  - sqs:ReceiveMessage
  - sqs:DeleteMessage
  - sqs:GetQueueAttributes
  - dynamodb:PutItem

- lambda_function-request_reader-execution_role  

  Permission Required:
  
  - dynamodb:Query

- lambda_function-sns_control-execution_role

  Permission Required:
  
  - sns:Subscribe
  - sns:Unsubscribe
  - sns:ListSubscriptionsByTopic

- lambda_function-flagger_control-execution_role

  Permission Required:
  
  - ssm:GetParameter
  - ssm:PutParameter

## API Gateway Variables

| Variable Name            | type   | required | default |
| ------------------------ | ------ | -------- | ------- |
| api_gateway-account-role | string | yes      | null    |
| api_gateway-enable-logs  | bool   | yes      | false   |

- api_gateway-account-role
  
  Permission Required:
  - logs:CreateLogGroup
  - logs:CreateLogStream
  - logs:DescribeLogGroups
  - logs:DescribeLogStreams
  - logs:PutLogEvents
  - logs:GetLogEvents
  - logs:FilterLogEvents

  Role Assumed by: `Service: apigateway.amazonaws.com`

- api_gateway-enable-logs

  possible valuse: true | false

  If set to `true` terraform will not enable logging on api gateway. Thus `api_gateway-account-role` are not needed. And `api_gateway_account` resource will not be created.

## Content Flagger Setting Variables

| Variable Name    | type   | required | default |
| ---------------- | ------ | -------- | ------- |
| bedrock-model-id | string | yes      | null    |
| bypass-flagger   | bool   | yes      | false   |
| always-flag      | bool   | yes      | false   |

- bedrock-model-id
  
  The aws bedrock model id, content flagger will use.

- bypass-flagger

  This variable can be changed in the web interface. If set to true. All content will not be flagged regardless.

- always-flag

  This variable can be changed in the web interface. If set to true. All content will be flagged regardless, and will overide `bypass-flagger`

## Web Interface Settings Variables

| Variable Name  | type         | required | default |
|----------------|--------------|----------|---------|
| admin-email    | list(string) | yes      | []      |
| use-cloudfront | bool         | yes      | true    |

- admin-email

  List of emails to subscribe to sns topic which send alert when content is flagged. Can leave empty as subscribers can be deleted and added in the web interafce.

- use-cloudfront
  
  Control the use of cloud front. Because AWS Acaedmy does not allow the use of Cloudfront. Setting this value to false will updload API.txt to the s3 bucket. And S3 bucket website will be used instead of cloudfront.
  