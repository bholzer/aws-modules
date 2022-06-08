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

variable "default_throttling_burst_limit" {
  type = number
  description = "Default throttling burst limit for routes"
  default = 50
}

variable "default_throttling_rate_limit" {
  type = number
  description = "Default throttling rate limit for routes"
  default = 100
}

variable "routes" {
  type = any
  description = "Object mapping routes to integration configurations"
}

variable "authorizers" {
  type = map(object({
    source = string
    audience = list(string)
    issuer = string
  }))
  description = "A map of named authorizers, which can be added to routes"
  default = {}
}

variable "tags" {
  type = map(string)
  default = {}
}