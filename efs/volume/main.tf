/**
 *  # EFS Volume
 *
 *  Creates an EFS volume and mount targets
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

resource "aws_efs_file_system" "this" {
  encrypted = var.encrypted
  kms_key_id = var.kms_key_id
  performance_mode = var.performance_mode

  dynamic "lifecycle_policy" {
    for_each = var.lifecycle_policy == null ? [] : [1]

    content {
      transition_to_ia = try(var.lifecycle_policy.transition_to_ia, null)
      transition_to_primary_storage_class = try(var.lifecycle_policy.transition_to_primary_storage_class, null)
    }
  }

  tags = merge(var.tags, {Name=var.name})
}

resource "aws_security_group" "this" {
  name = "${var.name}-efs"
  description = "Grants access to the EFS volume for ${var.name}"
  vpc_id = var.vpc_id

  egress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    description = "EFS out"
  }

  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    description = "EFS in"
  }

  tags = var.tags
}

resource "aws_efs_mount_target" "this" {
  for_each = toset(var.subnet_ids)
  file_system_id = aws_efs_file_system.this.id
  subnet_id = each.value
  security_groups = [aws_security_group.this.id]
}
