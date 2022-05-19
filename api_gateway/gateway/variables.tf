variable "name" {
  type = string
  description = "Name of the API Gateway"
}

variable "description" {
  type = string
  description = "Description of the gateway"
  default = null
}

variable "auto_deploy" {
  type = bool
  description = "Whether to automatically deploy changes to the gateway"
  default = true
}

variable "routes" {
  type = any
  description = "Object mapping routes to integration configurations"
}

variable "tags" {
  type = map(string)
  default = {}
}