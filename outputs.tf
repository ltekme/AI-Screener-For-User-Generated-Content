output "api_gateway-invoke_url" {
  value = aws_apigatewayv2_stage.main.invoke_url
}

output "web-interafce-bucket-name" {
  value = aws_s3_bucket.web-interafce.bucket
}

output "web-interafce-cloudfront-domain-name" {
  value = aws_cloudfront_distribution.main.domain_name  
}