/*########################################################
CloudFront distribution for web interface

# main fix for s3 bucket website 403 and 404 error

########################################################*/
resource "aws_cloudfront_origin_access_identity" "main-web-interface-bucket" {}

resource "aws_cloudfront_distribution" "main" {

  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.web-interafce.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.web-interafce.bucket_regional_domain_name}"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main-web-interface-bucket.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    viewer_protocol_policy = "redirect-to-https"

    // Get from console
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"

    target_origin_id = "S3-${aws_s3_bucket.web-interafce.bucket_regional_domain_name}"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

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
