/**
 *  # ECS Task Definition
 *
 *  Creates an ECS task definition with provided container definitions.
 *  Also created are a log group, SSM parameters and necessary IAM resources.
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

data "aws_caller_identity" "this" {}
data "aws_region" "this" {}
data "aws_partition" "this" {}

locals {
  param_arn_base = join(":", [
    "arn",
    data.aws_partition.this.partition,
    "ssm",
    data.aws_region.this.name,
    data.aws_caller_identity.this.account_id,
    "parameter"
  ])

  param_arn = "${local.param_arn_base}/${var.name}/*"

  container_secrets = [ for name, param in aws_ssm_parameter.params: { name = name, valueFrom = param.arn } ]
  containers = [
    for container in var.containers:
      merge(container, {
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group = aws_cloudwatch_log_group.task_definition.name
            awslogs-region = data.aws_region.this.name
            awslogs-stream-prefix = "${var.name}-${container.name}"
          }
        }
        mountPoints = [
          for volume in var.volumes:
            {
              containerPath = volume.path
              sourceVolume = volume.name
            }
        ]
        secrets = local.container_secrets
      })
  ]
}

data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  name = "${var.name}-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json

  tags = var.tags
}

data "aws_iam_policy_document" "task_execution" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ssm:DescribeParameters",
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:GetParametersByPath"
    ]
    resources = [local.param_arn]
  }
}

resource "aws_iam_role_policy" "task_execution" {
  name = "${var.name}-execution"
  role = aws_iam_role.task_execution.id
  policy = data.aws_iam_policy_document.task_execution.json
}

resource "aws_ssm_parameter" "params" {
  for_each = var.parameters

  name = "/${var.name}/${each.key}"
  value = each.value
  type = "String"

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "task_definition" {
  name = var.name
  retention_in_days = var.log_retention

  tags = var.tags
}

resource "aws_ecs_task_definition" "this" {
  family = var.name
  container_definitions = jsonencode(local.containers)
  requires_compatibilities = var.launch_types
  network_mode = var.network_mode
  cpu = var.cpu
  memory = var.memory
  execution_role_arn = aws_iam_role.task_execution.arn
  task_role_arn = aws_iam_role.task_execution.arn

  dynamic "volume" {
    for_each = var.volumes

    content {
      name = volume.value.name
    }
  }
}