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

resource "aws_s3_bucket_website_configuration" "web-interafce" {
  // enable static website hosting
  bucket = aws_s3_bucket.web-interafce.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.web-interafce.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "web-interafce" {
  // Bucket Policy for public access
  bucket = aws_s3_bucket.web-interafce.id
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect    = "Allow",
          Principal = "*",
          Action    = "s3:GetObject",
          Resource  = "${aws_s3_bucket.web-interafce.arn}/*",
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
