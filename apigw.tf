/*########################################################
API Gateway

########################################################*/
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project-name}-API"
  protocol_type = "HTTP"

  cors_configuration {
    allow_methods = ["*"]
    allow_origins = ["*"]
  }
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = replace(replace("${var.project-name}_API_Stage", " ", "_"), "-", "_")
  auto_deploy = true

  dynamic "access_log_settings" {
    for_each = var.api_gateway-enable-logs == true ? toset([0]) : toset([])
    content {
      destination_arn = aws_cloudwatch_log_group.main-api_gateway[0].arn
      format = jsonencode({
        requestId               = "$context.requestId",
        ip                      = "$context.identity.sourceIp",
        requestTime             = "$context.requestTime",
        httpMethod              = "$context.httpMethod",
        status                  = "$context.status",
        protocol                = "$context.protocol",
        integrationErrorMessage = "$context.integrationErrorMessage",
        errorMessage            = "$context.error.message"
      })
    }
  }

}

resource "aws_apigatewayv2_deployment" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  description = "${var.project-name}-API-Deployment"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_route.submit_post_post
  ]
}


/*########################################################
API Gateway Log

########################################################*/
resource "aws_cloudwatch_log_group" "main-api_gateway" {
  count             = var.api_gateway-enable-logs == true ? 1 : 0
  name              = "/aws/apigateway/${aws_apigatewayv2_api.main.id}"
  retention_in_days = 7
}

resource "aws_api_gateway_account" "main-api_gateway" {
  count               = var.api_gateway-enable-logs == true ? 1 : 0
  cloudwatch_role_arn = var.api_gateway-account-role == null ? aws_iam_role.main-api_gateway[0].arn : var.api_gateway-account-role
}

resource "aws_iam_role" "main-api_gateway" {
  count = var.api_gateway-enable-logs == true && var.api_gateway-account-role == null ? 1 : 0
  name  = replace(replace("${var.project-name}-Main-API-Gateway-Role", " ", "_"), "-", "_")
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "cloudwatch-logs"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "logs:GetLogEvents",
            "logs:FilterLogEvents",
          ],
          Resource = ["*"]
        }
      ]
    })
  }
}


/*########################################################
API Gateway Resource

Path: /submit_post

########################################################*/
resource "aws_apigatewayv2_route" "submit_post" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /submit_post"
  target    = "integrations/${aws_apigatewayv2_integration.submit_post.id}"
}

resource "aws_apigatewayv2_integration" "submit_post" {
  api_id              = aws_apigatewayv2_api.main.id
  credentials_arn     = var.api_gateway-route-submit-integration-role-arn == null ? aws_iam_role.main-api_gateway-integration-submit_post[0].arn : var.api_gateway-route-submit-integration-role-arn
  description         = "SQS queue integration"
  integration_type    = "AWS_PROXY"
  integration_subtype = "SQS-SendMessage"
  request_parameters = {
    "QueueUrl"    = "${aws_sqs_queue.user_submit_post.url}"
    "MessageBody" = "$request.body"
  }
}

resource "aws_iam_role" "main-api_gateway-integration-submit_post" {
  count = var.api_gateway-route-submit-integration-role-arn == null ? 1 : 0
  name  = "${replace(var.project-name, " ", "_")}-API-Gateway-submit_post-integration"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "sqs-send-message"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow",
          Action   = "sqs:SendMessage",
          Resource = ["${aws_sqs_queue.user_submit_post.arn}"]
        }
      ]
    })
  }
}
