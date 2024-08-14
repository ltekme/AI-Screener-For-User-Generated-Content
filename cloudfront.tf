/*########################################################
CloudFront Distribution locals

########################################################*/
locals {
  cloudfront = {
    origin = {
      s3_bucket = {
        origin_id = "S3-${aws_s3_bucket.web-interafce.bucket_regional_domain_name}"
      }
      api_gateway = {
        origin_id = "API-${aws_apigatewayv2_api.main.id}"
      }
    }
  }
}


/*########################################################
CloudFront distribution for web interface

mainly bypass s3 bucket website 403 and 404 error for react js

########################################################*/
resource "aws_cloudfront_origin_access_control" "main-web-interface-bucket" {
  count                             = var.use-cloudfront == true ? 1 : 0
  name                              = "${replace(var.project-name, " ", "-")}-web-interface-bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "main" {
  count = var.use-cloudfront == true ? 1 : 0

  enabled             = true
  default_root_object = "index.html"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  // reactjs web intreface bucket
  origin {
    domain_name              = aws_s3_bucket.web-interafce.bucket_regional_domain_name
    origin_id                = local.cloudfront.origin.s3_bucket.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.main-web-interface-bucket[0].id
  }

  // api gateway
  origin {
    domain_name = replace(aws_apigatewayv2_api.main.api_endpoint, "https://", "")
    origin_path = "/${aws_apigatewayv2_stage.main.name}"
    origin_id   = local.cloudfront.origin.api_gateway.origin_id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    viewer_protocol_policy = "redirect-to-https"

    // Get from console
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" // Managed-CachingOptimized
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" // Managed-CORS-S3Origin

    target_origin_id = local.cloudfront.origin.s3_bucket.origin_id
  }

  ordered_cache_behavior {
    path_pattern           = "/api/*"
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["HEAD", "GET", "OPTIONS"]
    viewer_protocol_policy = "redirect-to-https"

    // Get from console
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" // Managed-CachingDisabled
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac" // Managed-AllViewerExceptHostHeader

    target_origin_id = local.cloudfront.origin.api_gateway.origin_id
  }

  // Bypass error response for reactjs
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }
}
