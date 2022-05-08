terraform {
  required_version = ">= 1.1.9"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.12.1"
    }
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.name

  setting {
    name = "containerInsights"
    value = var.container_insights_enabled ? "enabled" : "disabled"
  }

  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = var.capacity_providers
  default_capacity_provider_strategy {
    capacity_provider = var.default_provider
    base = var.default_provider_base
    weight = var.default_provider_weight
  }
}