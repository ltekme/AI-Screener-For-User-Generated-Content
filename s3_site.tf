/*########################################################
S3 bucket for web interface

########################################################*/
resource "aws_s3_bucket" "web-interafce" {
  // Create a S3 bucket for the web interface hosting
  bucket        = "${lower(replace(var.project-name, " ", "-"))}-${random_string.web-interafce-bucket-suffix.result}"
  force_destroy = true
}

resource "random_string" "web-interafce-bucket-suffix" {
  // random suffix for unique bucket name
  length  = 16
  lower   = true
  upper   = false
  special = false
  numeric = true
}

resource "aws_s3_bucket_policy" "web-interafce" {
  // Bucket Policy for CloudFront OAI
  bucket = aws_s3_bucket.web-interafce.id
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Principal = {
            AWS = ["${aws_cloudfront_origin_access_identity.main-web-interface-bucket.iam_arn}"]
          }
          Action   = "s3:GetObject",
          Resource = "${aws_s3_bucket.web-interafce.arn}/*",
        },
      ],
    }
  )
}


/*########################################################
S3 bucket content for web interface

########################################################*/
resource "null_resource" "web-interface-node-build" {
  // Build the web interface
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/web_interface"
    command     = "npm install && npm run build"
  }
}

resource "null_resource" "web-interface-content-sync" {
  // Copy the web-interface folder to the S3 bucket
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/web_interface"
    command     = "aws s3 sync build s3://${aws_s3_bucket.web-interafce.id} --delete --region ${var.aws-region}"
  }

  // sync after build and bucket creation
  depends_on = [
    aws_s3_bucket.web-interafce,
    resource.null_resource.web-interface-node-build
  ]
}

resource "aws_s3_object" "web-interface-api-url-file" {
  // Create a file with the API URL for web interface
  bucket = aws_s3_bucket.web-interafce.id
  key    = "API.txt"

  content      = aws_apigatewayv2_stage.main.invoke_url
  content_type = "text/plain"

  // Put file after sync content
  depends_on = [null_resource.web-interface-content-sync]
}
