/**
 *  # S3 Bucket
 *
 *  Creates an S3 bucket and associated configuration resources.
 */

terraform {
  required_version = ">= 1.1.9"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.12.1"
    }
  }

  backend "s3" {}
}

data "aws_caller_identity" "this" {}

locals {
  bucket_policy = (var.bucket_policy_json == null ?
                     (var.acl == "public-read" ? data.aws_iam_policy_document.public.json : null)
                     : var.bucket_policy_json)
  notifications = concat(var.lambda_notifications, var.sns_notifications, var.sqs_notifications)
  lambda_notification_names = [
    for notification in var.lambda_notifications:
      reverse(split(":", notification.lambda_function_arn))[0]
  ]
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.name}-${data.aws_caller_identity.this.account_id}"
  force_destroy = var.force_destroy
  object_lock_enabled = var.object_lock_enabled

  tags = var.tags
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl = var.acl
}

resource "aws_s3_bucket_logging" "this" {
  for_each = toset(var.log_bucket_name == null ? [] : [var.log_bucket_name])
  bucket = aws_s3_bucket.this.id
  target_bucket = var.log_bucket_name
  target_prefix = "log/${aws_s3_bucket.this.id}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.sse_enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
      kms_master_key_id = var.sse_kms_key_id
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count = var.versioning_enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning_suspended ? "Suspended" : "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.block_access ? 1 : 0
  bucket = aws_s3_bucket.this.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "public" {
  statement {
    actions = ["s3:GetObject"]
    principals {
      type = "*"
      identifiers = ["*"]
    }
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "this" {
  count = local.bucket_policy == null ? 0 : 1
  bucket = aws_s3_bucket.this.id
  policy = local.bucket_policy
}

data "aws_iam_policy_document" "read_bucket" {
  statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:GetLifecycleConfiguration",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "write_bucket" {
  statement {
    actions = [
      "s3:PutLifecycleConfiguration",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion"
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "read" {
  name = "${aws_s3_bucket.this.id}-read"
  policy = data.aws_iam_policy_document.read_bucket.json
}

resource "aws_iam_policy" "write" {
  name = "${aws_s3_bucket.this.id}-write"
  policy = data.aws_iam_policy_document.write_bucket.json
}

resource "aws_s3_bucket_notification" "this" {
  count = length(local.notifications) == 0 ? 0 : 1
  bucket = aws_s3_bucket.this.id

  dynamic "lambda_function" {
    for_each = var.lambda_notifications
    content {
      lambda_function_arn = lambda_function.value.function_arn
      events = lambda_function.value.events
      filter_prefix = try(lambda_function.value.filter_prefix)
      filter_suffix = try(lambda_function.value.filter_suffix)
    }
  }

  dynamic "topic" {
    for_each = var.sns_notifications
    content {
      topic_arn = topic.value.topic_arn
      events = topic.value.events
      filter_prefix = try(topic.value.filter_prefix)
      filter_suffix = try(topic.value.filter_suffix)
    }
  }

  dynamic "queue" {
    for_each = var.sqs_notifications
    content {
      queue_arn = queue.value.queue_arn
      events = queue.value.events
      filter_prefix = try(queue.value.filter_prefix)
      filter_suffix = try(queue.value.filter_suffix)
    }
  }
}

resource "aws_lambda_permission" "notification" {
  for_each = toset(local.lambda_notification_names)
  action = "lambda:InvokeFunction"
  function_name = each.value
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.this.arn
}
