# AI-Screener-For-User-Generated-Content

A concept for using bedrock to flag user generated content. For technical details, I will put out a bog detailing everything in this project.

## Table of contents

- [AI-Screener-For-User-Generated-Content](#ai-screener-for-user-generated-content)
  - [Table of contents](#table-of-contents)
  - [Before everything speach](#before-everything-speach)
  - [Deploying](#deploying)
    - [Deploying on your own account](#deploying-on-your-own-account)
    - [Deploying on AWS Acaedmy Learner Lab Account](#deploying-on-aws-acaedmy-learner-lab-account)
  - [Variable Defination](#variable-defination)
  - [Using the Web Interface](#using-the-web-interface)

## Before everything speach

About The AI. Even though the title is AI-Screener-For-User-Generated-Content the main focus for me is not the AI part, please spear me some lack if the model prompt is terrable, at least it works.  Instead, my goal is to try to build a `serverless + decoupled` "system". This project have 5 lambda function, and 2 SQS queue, coupling everyting together. And everything can be done with a single lambda function, but what's the fun in that.

## Deploying

also see: [https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files)

### Deploying on your own account

1. Change Bedrock Model ID

   When creating this thing. I only requested access to [`claude-3-haiku`](https://aws.amazon.com/bedrock/claude/), so that is the defaule model id. To change it. Set the `bedrock-model-id` to your model id in the variables.

2. Applying resources

   ```sh
   terraform init
   terrafrom apply
   ```

### Deploying on AWS Acaedmy Learner Lab Account

1. Setup enviroments

   Due to the way AWS Acaedmy Learner Lab is designed. Various resources creation need to be skipped, namely IAM. And some functionality mught not work properly.

   By dafault, terraform will create the necessary iam roles for lambda functions, however the lab enviroment deny the creation of IAM roles with a single role be used on all resources.

   The way things are constructed here works around that by check if an execution role is provided, if provided, terraform will not create the IAM role needed, and use the one provided instead. For more information, see [Variable Defination](#variable-defination).

   Due to Acaedmy Learner Lab limitations. `always-flag` or `bypass-flagger` must be set to true, as learner lab account lack bedrock invoke_model permission. If both set to false, all content submitted will be flagged due to insufficent permission from content flagger lambda function.

   ```tfvar
   # terrafrom.tfvarsF
   lambda_function-user_request-execution_role    = "arn:aws:iam::123456789012:role/LabRole"
   lambda_function-content_flagger-execution_role = "arn:aws:iam::123456789012:role/LabRole"
   lambda_function-request_writer-execution_role  = "arn:aws:iam::123456789012:role/LabRole"
   lambda_function-request_reader-execution_role  = "arn:aws:iam::123456789012:role/LabRole"
   lambda_function-sns_control-execution_role     = "arn:aws:iam::123456789012:role/LabRole"
   lambda_function-flagger_control-execution_role = "arn:aws:iam::123456789012:role/LabRole"
   always-flag = true
   ```

   Optional roles are `api_gateway-account-role`. If `api_gateway-enable-logs` is set to false. The role used by api gateway will not be created and logging for the aip gateway will be diabled, see [Variable Defination](#variable-defination).

2. Apply resources

   ```sh
   terraform init
   terrafrom apply
   ```

## Variable Defination

refer to [docs/variables.md](docs/variables.md)

## Using the Web Interface

refer to [docs/web-interface.md](docs/web-interface.md)
