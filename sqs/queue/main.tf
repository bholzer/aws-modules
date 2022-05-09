terraform {
  required_version = ">= 1.1.9"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.12.1"
    }
    archive = {
      source = "hashicorp/archive"
    }
  }
}

data "aws_caller_identity" "this" {}

resource "aws_sqs_queue" "this" {
  name = var.name
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds = var.message_retention_seconds
  max_message_size = var.max_message_size
  delay_seconds = var.delay_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds
  fifo_queue = var.fifo
  fifo_throughput_limit = var.fifo_throughput_limit
  content_based_deduplication = var.content_based_deduplication
  deduplication_scope = var.deduplication_scope

  tags = var.tags
}

resource "time_sleep" "wait" {
  depends_on = [ aws_sqs_queue.this ]
  create_duration = "90s"
}

# Allow access from this account only
data "aws_iam_policy_document" "base" {
  statement {
    actions = [
      "SQS:GetQueueAttributes",
      "SQS:ReceiveMessage",
      "SQS:DeleteMessage",
      "SQS:SendMessage"
    ]
    resources = [aws_sqs_queue.this.arn]
    principals {
      type = "AWS"
      identifiers = [data.aws_caller_identity.this.account_id]
    }
  }
}

resource "aws_sqs_queue_policy" "this" {
  depends_on = [ time_sleep.wait ]
  queue_url = aws_sqs_queue.this.id
  policy = data.aws_iam_policy_document.base.json
}