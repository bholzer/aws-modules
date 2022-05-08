variable "name" {
  type = string
  description = "Name of the cluster"
}

variable "capacity_providers" {
  type = list(string)
  description = "List of capacity providers for the cluster"
  default = [ "FARGATE" ]
}

variable "default_provider" {
  type = string
  description = "Default cluster capacity provider"
  default = "FARGATE"
}

variable "default_provider_base" {
  type = number
  description = "Base capacity for the default provider"
  default = 1
}

variable "default_provider_weight" {
  type = number
  description = "Weight to assign to the defaul provider"
  default = 100
}

variable "container_insights_enabled" {
  type = bool
  description = "Turn on container insights for more complete cluster metrics"
  default = false
}

variable "tags" {
  type = map(string)
  default = {}
}