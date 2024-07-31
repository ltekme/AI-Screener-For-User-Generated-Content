/*########################################################
SSM Parameter Store for Content Flagger

########################################################*/
locals {
  ssm = {
    prefix = lower(replace(var.project-name, " ", "-"))
  }
}

resource "aws_ssm_parameter" "content_flagger-bypass-flagger" {
  // bedrock-model-id
  name  = "/${local.ssm.prefix}/bypass-flagger"
  type  = "String"
  value = tostring(var.bypass-flagger)
}

resource "aws_ssm_parameter" "content_flagger-always-flag" {
  // bedrock-model-id
  name  = "/${local.ssm.prefix}/always-flag"
  type  = "String"
  value = tostring(var.always-flag)
}
