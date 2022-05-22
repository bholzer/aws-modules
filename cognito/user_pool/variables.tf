variable "name" {
  type = string
  description = "The name of the user pool and associated resources"
}

variable "callback_urls" {
  type = list(string)
  description = "List of allows callback URLs"
  default = null
}

variable "allowed_oauth_flows" {
  type = list(string)
  description = "List of alllowed Oauth flows"
  default = null
}

variable "allowed_oauth_scopes" {
  type = list(string)
  description = "List of allowed Oauth scopes"
  default = null
}

variable "allowed_oauth_flows_user_pool_client" {
  type = bool
  description = "Whether client is allowed to use Oauth when interaction with user pools"
  default = false
}

variable "supported_identity_providers" {
  type = list(string)
  description = "List of provider names for the identity providers that are supported on this client"
  default = null
}

variable "tags" {
  type = map(string)
  default = {}
}
