output "api_gateway-invoke_url" {
  value = aws_apigatewayv2_stage.main.invoke_url
}

output "web-interafce-url" {
  value = var.use-cloudfront == true ? "https://${aws_cloudfront_distribution.main[0].domain_name}/" : "http://${aws_s3_bucket_website_configuration.web-interafce[0].website_endpoint}"
}
