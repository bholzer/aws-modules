variable "name" {
  type = string
  description = "Task definition name"
}

variable "containers" {
  type = list(any)
  description = "A list of container definitions for the task. Structure documentation: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definitions"
}

variable "parameters" {
  type = map(string)
  description = "A map of variables to supply to the containers. These will be created in the param store."
  default = {}
}

variable "log_retention" {
  type = number
  description = "Number of days to keep logs"
  default = 14
}

variable "launch_types" {
  type = list(string)
  description = "Launch types for the tasks. Options are `EC2` and `FARGATE`"
  default = [ "FARGATE" ]
}

variable "cpu" {
  type = number
  description = "CPU to allocate to tasks"
  default = 256
}

variable "memory" {
  type = number
  description = "Memory to allocate to tasks"
  default = 512
}

variable "network_mode" {
  type = string
  description = "Network mode for containers of task"
  default = "awsvpc"
}

variable "volumes" {
  type = list(object({
    name = string
    path = string
  }))
  description = "Volumes to mount to containers of task"
  default = []
}

variable "tags" {
  type = map(string)
  default = {}
}