/**
 *  # ECS Service
 *
 *  Creates an ECS service for maintaining a set of tasks. Also creates security group and autoscaling target as needed
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

locals {
  security_group_ids = concat(
    try(aws_security_group.this[0].id, []),
    try(var.network_configuration.security_group_ids, [])
  )
}

data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_name
}

resource "aws_ecs_service" "this" {
  name = var.name
  cluster = data.aws_ecs_cluster.this.arn
  deployment_maximum_percent = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count = var.desired_count
  force_new_deployment = var.force_new_deployment
  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  launch_type = var.launch_type
  platform_version = var.launch_type == "FARGATE" ? var.platform_version : null
  propagate_tags = var.propagate_tags
  task_definition = var.task_definition
  wait_for_steady_state = var.wait_for_steady_state

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategies

    content {
      base = try(capacity_provider_strategy.value.base, null)
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight = capacity_provider_strategy.value.weight
    }
  }

  dynamic "deployment_circuit_breaker" {
    for_each = var.deployment_circuit_breaker_enabled ? [] : [1]

    content {
      enable = var.deployment_circuit_breaker_enabled
      rollback = var.deployment_circuit_breaker_rollback
    }
  }

  deployment_controller {
    type = var.deployment_controller
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer == null ? [] : [1]

    content {
      target_group_arn = var.load_balancer.target_group_arn
      container_name = var.load_balancer.container_name
      container_port = var.load_balancer.container_port
    }
  }

  dynamic "network_configuration" {
    for_each = var.network_configuration == null ? [] : [1]

    content {
      subnets = var.network_configuration.subnet_ids
      security_groups = local.security_group_ids
      assign_public_ip = try(var.network_configuration.assign_public_ip, null)
    }
  }

  tags = var.tags
}

resource "aws_security_group" "this" {
  count = var.network_configuration == null ? 0 :1
  name = "${var.name}-sg"
  description = "Security group for ${var.name}"
  vpc_id = var.network_configuration.vpc_id

  dynamic "egress" {
    for_each = var.egress

    content {
      from_port = egress.value.port
      to_port = egress.value.port
      protocol = "tcp"
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  dynamic "ingress" {
    for_each = var.ingress

    content {
      from_port = ingress.value.port
      to_port = ingress.value.port
      protocol = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  tags = var.tags
}

resource "aws_appautoscaling_target" "this" {
  count = var.autoscaling_enabled ? 1 : 0
  max_capacity = var.max_capacity
  min_capacity = var.min_capacity
  resource_id = "service/${data.aws_ecs_cluster.cluster.cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}
