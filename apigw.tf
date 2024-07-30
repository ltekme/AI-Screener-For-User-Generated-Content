/*########################################################
API Gateway

########################################################*/
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project-name}-API"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "GET", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age       = 300
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
    aws_apigatewayv2_route.submit_post
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

Path: /api/submit_post

########################################################*/
resource "aws_apigatewayv2_route" "submit_post" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /api/submit_post"
  target    = "integrations/${aws_apigatewayv2_integration.submit_post.id}"
}

resource "aws_apigatewayv2_integration" "submit_post" {
  api_id               = aws_apigatewayv2_api.main.id
  passthrough_behavior = "WHEN_NO_MATCH"
  integration_type     = "AWS_PROXY"
  integration_method   = "POST"
  integration_uri      = module.user_request_lambda.lambda_function.invoke_arn
}

resource "aws_lambda_permission" "submit_post" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.user_request_lambda.lambda_function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*/*"
}


/*########################################################
API Gateway Resource

Path: /dynamo_query

########################################################*/
resource "aws_apigatewayv2_route" "dynamo_query" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /api/dynamo_query"
  target    = "integrations/${aws_apigatewayv2_integration.dynamo_query.id}"
}

resource "aws_apigatewayv2_integration" "dynamo_query" {
  api_id               = aws_apigatewayv2_api.main.id
  passthrough_behavior = "WHEN_NO_MATCH"
  integration_type     = "AWS_PROXY"
  integration_method   = "POST"
  integration_uri      = module.request_reader_lambda.lambda_function.invoke_arn
}

resource "aws_lambda_permission" "dynamo_query" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.request_reader_lambda.lambda_function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*/*"
}
