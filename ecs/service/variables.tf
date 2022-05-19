variable "name" {
  type = string
  description = "The name of the ECS service."
}

variable "cluster_name" {
  type = string
  description = "The name of the cluster where the service is to be run."
}

variable "deployment_maximum_percent" {
  type = number
  description = "The maximum percent service scale that the service can reach during deployment."
  default = 200
}

variable "deployment_minimum_healthy_percent" {
  type = number
  description = "The minimum healthy percent that the service can reach during deployment."
  default = 50
}

variable "desired_count" {
  type = number
  description = "Desired service scale."
  default = 0
}

variable "force_new_deployment" {
  type = bool
  description = "Whether to force new deployment when service is updated."
  default = false
}

variable "health_check_grace_period_seconds" {
  type = number
  description = "Number of seconds to wait for grace period of health check failures."
  default = null
}

variable "launch_type" {
  type = string
  description = "The launch type of the service. Valid values are `EC2`, `FARGATE` and `EXTERNAL`."
  default = "FARGATE"
}

variable "platform_version" {
  type = string
  description = "Platform version for `FARGATE` launch_type."
  default = null
}

variable "propagate_tags" {
  type = string
  description = "Whether to propagate tags from service or task definition. Valid values are `SERVICE` and `TASK_DEFINITION`"
  default = null
}

variable "task_definition" {
  type = string
  description = "family:revision or full ARN of task definition for the service."
}

variable "wait_for_steady_state" {
  type = bool
  description = "Whether terraform should wait for service to reach steady state before finishing resource."
  default = false
}

variable "capacity_provider_strategies" {
  type = list(any)
  description = <<-EOL
    List of capacity provider strategies.
    Structure:
      list(object({
        base = number (optional) Minimum number of tasks to run on the specified provider
        capacity_provider = string (required) Name of the capacity provider to use for this strategy
        weight = number (required) Relative percentage of total number of tasks that should use the specified provider
      }))
  EOL
  default = []
}

variable "deployment_circuit_breaker_enabled" {
  type = bool
  description = "Enables the deployment circuit breaker for the service."
  default = false
}

variable "deployment_circuit_breaker_rollback" {
  type = bool
  description = "Emables deployment circuit breaker rollback."
  default = true
}

variable "deployment_controller" {
  type = string
  description = "Deployment controller type. Valid values are `CODE_DEPLOY`, `ECS` and `EXTERNAL`"
  default = "ECS"
}

variable "load_balancer" {
  type = object({
    target_group_arn = string
    container_name = string
    container_port = string
  })
  description = "The load balancer configuration for the service."
  default = null
}

variable "network_configuration" {
  type = any
  description = <<-EOL
    Network configuration for the service.
    Structure:
      object({
        vpc_id = string (required)
        subnet_ids = list(string) (required)
        assign_public_ip = bool (optional)
      })
  EOL
}

variable "egress" {
  type = list(object({
    port = number
    cidr_blocks = list(string)
    description = string
  }))
  description = "Egress rules for security group attached to service."
  default = []
}

variable "ingress" {
  type = list(object({
    port = number
    cidr_blocks = list(string)
    description = string
  }))
  description = "Ingress rules for security group attached to service."
  default = []
}

variable "autoscaling_enabled" {
  type = bool
  description = "Creates an autoscaling target for the service."
  default = false
}

variable "min_capacity" {
  type = number
  description = "When autoscaling enabled, the minimum number of tasks for the service."
  default = 0
}

variable "max_capacity" {
  type = number
  description = "When autoscaling enabled, the maximum number of tasks for the service."
  default = 3
}

variable "tags" {
  type = map(string)
  default = {}
}
