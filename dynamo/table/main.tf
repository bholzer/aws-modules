/**
 *  # DynamoDB Table
 *
 *  Creates a DynamoDB table and policies for access
 */

terraform {
  required_version = ">= 1.1.9"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.12.1"
    }
  }
}

resource "aws_dynamodb_table" "this" {
  name = var.name
  billing_mode = var.billing_mode
  hash_key = var.hash_key
  range_key = var.range_key
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  read_capacity = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  restore_source_name = var.restore_source_name
  restore_to_latest_time = var.restore_to_latest_time
  restore_date_time = var.restore_date_time
  stream_enabled = var.stream_enabled
  stream_view_type = var.stream_view_type
  table_class = var.table_class

  dynamic "attribute" {
    for_each = var.attributes

    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  ttl {
    enabled = var.ttl_enabled
    attribute_name = var.ttl_attribute_name
  }

  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes

    content {
      name = local_secondary_index.value.name
      range_key = local_secondary_index.value.range_key
      projection_type = local_secondary_index.value.projection_type
      non_key_attributes = try(local_secondary_index.value.non_key_attributes, null)
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes

    content {
      name = global_secondary_index.value.name
      write_capacity = global_secondary_index.value.write_capacity
      read_capacity = global_secondary_index.value.read_capacity
      hash_key = global_secondary_index.value.hash_key
      range_key = try(global_secondary_index.value.range_key, null)
      projection_type = global_secondary_index.value.projection_type
      non_key_attributes = try(global_secondary_index.value.non_key_attributes)
    }
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  dynamic "replica" {
    for_each = var.replicas

    content {
      region_name = replica.value.region_name
      kms_key_arn = try(replica.value.kms_key_arn, null)
    }
  }

  server_side_encryption {
    enabled = var.encryption_enabled
    kms_key_arn = var.kms_key_arn
  }

  timeouts {
    create = var.create_timeout
    update = var.update_timeout
    delete = var.delete_timeout
  }

  tags = var.tags
}

data "aws_iam_policy_document" "table_read" {
  statement {
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:Describe*",
      "dynamodb:List*",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:PartiQLSelect",
      "dynamodb:ConditionCheckItem",
      "dynamodb:GetRecords"
    ]
    Resource = [
      aws_dynamodb_table.this.arn,
      "${aws_dynamodb_table.this.arn}/index/*",
      "${aws_dynamodb_table.this.arn}/stream/*"
    ]
  }
}

data "aws_iam_policy_document" "table_write" {
  statement {
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:PartiQLDelete",
      "dynamodb:PartiQLInsert",
      "dynamodb:PartiQLUpdate"
    ]
    Resource = [ aws_dynamodb_table.this.arn ]
  }
}

resource "aws_iam_policy" "table_read" {
  name_prefix = "${var.name}-table-read-"
  policy = data.aws_iam_policy_document.table_read.json
}

resource "aws_iam_policy" "table_write" {
  name_prefix = "${var.name}-table-write-"
  policy = data.aws_iam_policy_document.table_write.json
}
