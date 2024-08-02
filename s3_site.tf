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

resource "aws_s3_bucket_policy" "web-interafce-oai" {
  count = var.use-cloudfront == true ? 1 : 0
  // Bucket Policy for CloudFront OAI
  bucket = aws_s3_bucket.web-interafce.id
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Principal = {
            AWS = ["${aws_cloudfront_origin_access_identity.main-web-interface-bucket[0].iam_arn}"]
          }
          Action   = "s3:GetObject",
          Resource = "${aws_s3_bucket.web-interafce.arn}/*",
        },
      ],
    }
  )
}


/*########################################################
S3 website for no CloudFront Distribution

Count based on use-cloudfront. Setup s3 website if cloudfront is not used

########################################################*/
resource "aws_s3_bucket_public_access_block" "web-interafce" {
  // Diable bucket block public access
  count                   = var.use-cloudfront == false ? 1 : 0
  bucket                  = aws_s3_bucket.web-interafce.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "web-interafce-public" {
  // Bucket Policy for public access
  count  = var.use-cloudfront == false ? 1 : 0
  bucket = aws_s3_bucket.web-interafce.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.web-interafce.arn}/*",
    }],
  })
}

resource "aws_s3_bucket_website_configuration" "web-interafce" {
  // Websit hosting config for not using cloudfront
  count  = var.use-cloudfront == false ? 1 : 0
  bucket = aws_s3_bucket.web-interafce.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}


/*########################################################
S3 bucket content for web interface

########################################################*/
data "archive_file" "web_interface" {
  // Create Zip on web interface folder
  type        = "zip"
  source_dir  = "${path.module}/web_interface"
  output_path = "web_interface.zip"
}

resource "null_resource" "web-interface-node-build" {
  // Build the web interface from node
  triggers = {
    src_hash = "${data.archive_file.web_interface.output_sha}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/web_interface"
    command     = "npm install && npm run build"
  }
}

resource "null_resource" "web-interface-content-sync" {
  // Copy the web-interface folder to the S3 bucket
  provisioner "local-exec" {
    working_dir = "${path.module}/web_interface"
    command     = "aws s3 sync build s3://${aws_s3_bucket.web-interafce.id} --delete --region ${var.aws-region}"
  }

  // trigger replace
  lifecycle {
    replace_triggered_by = [null_resource.web-interface-node-build]
  }

  // sync after build and bucket creation
  depends_on = [
    aws_s3_bucket.web-interafce,
    resource.null_resource.web-interface-node-build
  ]
}

resource "aws_s3_object" "web-interface-api-url-file" {
  count = var.use-cloudfront == false ? 1 : 0
  // Create a file with the API URL for web interface
  bucket       = aws_s3_bucket.web-interafce.id
  key          = "API.txt"
  content      = aws_apigatewayv2_stage.main.invoke_url
  content_type = "text/plain"

  // trigger replace
  lifecycle {
    replace_triggered_by = [null_resource.web-interface-content-sync]
  }

  // Put file after sync content
  depends_on = [null_resource.web-interface-content-sync]
}

resource "null_resource" "CF-invalidation" {
  // invalidation to replace API.txt
  count = var.use-cloudfront == true ? 1 : 0

  lifecycle {
    replace_triggered_by = [aws_s3_object.web-interface-api-url-file]
  }

  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.main[0].id} --paths '/API.txt' --region ${var.aws-region}"
  }
}
