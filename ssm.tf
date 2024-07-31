/*########################################################
SSM Parameter Store for Content Flagger

########################################################*/
locals {
  ssm = {
    prefix = lower(replace(var.project-name, " ", "-"))
  }
}

resource "aws_ssm_parameter" "content_flagger-bedrock-model-id" {
  // bedrock-model-id
  name  = "${loacl.ssm.prefix}/bedrock-model-id"
  type  = "String"
  value = var.bedrock-model-id
}

resource "aws_ssm_parameter" "content_flagger-bypass-flagger" {
  // bedrock-model-id
  name  = "${loacl.ssm.prefix}/bypass-flagger"
  type  = "String"
  value = var.bedrock-model-id
}

resource "aws_ssm_parameter" "content_flagger-bedrock-model-id" {
  // bypass-flagger
  name  = "${loacl.ssm.prefix}/bedrock-model-id"
  type  = "String"
  value = tostring(var.bypass-flagger)
}
