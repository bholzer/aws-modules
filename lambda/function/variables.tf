variable "name" {
  type = string
  description = "Name of the lambda function"
}

variable "description" {
  type = string
  description = "Description for the lambda"
  default = null
}

variable "runtime" {
  type = string
  description = "The runtime environment"
}

variable "handler" {
  type = string
  description = "The handler definition"
  default = "main.handler"
}

variable "environment" {
  type = map(string)
  description = "Environment variables"
  default = {}
}

variable "policy_arns" {
  type = list(string)
  description = "An additional list of policies to apply to the function"
  default = []
}

variable "memory_size" {
  type = number
  description = "Amount of memory to allocation to function"
  default = null
}

variable "timeout" {
  type = number
  description = "Number of seconds for function timeout"
  default = null
}

variable "log_retention" {
  type = number
  description = "Number of days to keep logs for the lambda"
  default = null
}

variable "vpc_config" {
  type = object({
    subnet_ids = list(string)
    security_group_ids = list(string)
  })
  description = "Place the lambda in the provided subnets and apply security groups. Enables lambda connectivity to VPC"
  default = null
}

variable "tags" {
  type = map(string)
  default = {}
}