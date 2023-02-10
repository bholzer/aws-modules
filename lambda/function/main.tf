/**
 *  # Lambda function
 *
 *  This module creates a lambda function, log group, and necessary IAM resources.
 */

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

  backend "s3" {}
}

locals {
  handler_module = split(".", var.handler)[0]
  handler_function = split(".", var.handler)[1]

  language = [ for lang, matched in {
    javascript = length(regexall("node", var.runtime)) > 0
    python = length(regexall("python", var.runtime)) > 0
    ruby = length(regexall("ruby", var.runtime)) > 0
  }: lang if matched ][0]

  extension = {
    javascript = "js"
    python = "py"
    ruby = "rb"
  }[local.language]

  stub = {
    javascript = "exports.${local.handler_function} =  async function(e,c) {}"
    python = "def ${local.handler_function}(e,c):\n  pass"
    ruby = "def ${local.handler_function}(e:,c:); end"
  }[local.language]

}

data "aws_iam_policy_document" "execution" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name = "${var.name}-execution"
  description = "Assume role for ${var.name}"
  assume_role_policy = data.aws_iam_policy_document.execution.json
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${var.name}"
  retention_in_days = var.log_retention
  tags = var.tags
}

data "aws_iam_policy_document" "write_logs" {
  statement {
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.lambda.arn}:*"]
  }
}

resource "aws_iam_policy" "write_logs" {
  name = "${var.name}-log-write"
  description = "Write logs for ${var.name}"
  policy = data.aws_iam_policy_document.write_logs.json
}

resource "aws_iam_role_policy_attachment" "logging" {
  role = aws_iam_role.execution.name
  policy_arn = aws_iam_policy.write_logs.arn
}

data "aws_iam_policy_document" "vpc_access" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "vpc_access" {
  count = var.vpc_config == null ? 0 : 1
  name = "${var.name}-vpc-access"
  description = "Allow ${var.name} to manage VPC components"
  policy = data.aws_iam_policy_document.vpc_access.json
}

data "aws_iam_policy_document" "combined" {
  count = length(var.policy_documents) > 0 ? 1 : 0
  source_policy_documents = var.policy_documents
}

resource "aws_iam_policy" "documents" {
  count = length(var.policy_documents) > 0 ? 1 : 0
  name = "${var.name}-extra-policies"
  description = "Extra policy for function ${var.name}"
  policy = data.aws_iam_policy_document.combined[0].json
}

resource "aws_iam_role_policy_attachment" "documents" {
  count = length(var.policy_documents) > 0 ? 1 : 0
  role = aws_iam_role.execution.name
  policy_arn = aws_iam_policy.documents[0].arn
}

resource "aws_iam_role_policy_attachment" "vpc_access" {
  count = var.vpc_config == null ? 0 : 1
  role = aws_iam_role.execution.name
  policy_arn = aws_iam_policy.vpc_access[0].arn
}

resource "aws_iam_role_policy_attachment" "arns" {
  for_each = toset(var.policy_arns)
  role = aws_iam_role.execution.name
  policy_arn = each.value
}

data "archive_file" "stub" {
  type = "zip"
  output_path = "${path.module}/stub.zip"
  source {
    content = local.stub
    filename = "${local.handler_module}.${local.extension}"
  }
}

resource "aws_lambda_function" "this" {
  function_name = var.name
  role = aws_iam_role.execution.arn
  description = var.description
  runtime = var.runtime
  filename = var.s3_source == null ? data.archive_file.stub.output_path : null
  s3_bucket = var.s3_source != null ? var.s3_source.bucket : null
  s3_key = var.s3_source != null ? var.s3_source.key : null
  s3_object_version = var.s3_source != null ? var.s3_source.version : null
  handler = var.handler
  memory_size = var.memory_size
  timeout = var.timeout

  dynamic "environment" {
    for_each = length(var.environment) > 0 ? [1] : []

    content {
      variables = var.environment
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [var.vpc_config]

    content {
      subnet_ids = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  tags = var.tags
}

data "aws_iam_policy_document" "deploy" {
  statement {
    actions = [
      "lambda:PublishVersion",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:GetFunctionConfiguration",
    ]
    resources = [aws_lambda_function.this.arn]
  }
}

resource "aws_iam_policy" "deploy" {
  name = "${var.name}-deploy"
  description = "Allow the deployment of ${aws_lambda_function.this.function_name}"
  policy = data.aws_iam_policy_document.deploy.json
}

data "aws_iam_policy_document" "invoke" {
  statement {
    actions = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.this.arn]
  }
}

resource "aws_iam_policy" "invoke" {
  name = "${var.name}-invoke"
  description = "Allow the invoking ${aws_lambda_function.this.function_name}"
  policy = data.aws_iam_policy_document.invoke.json
}
