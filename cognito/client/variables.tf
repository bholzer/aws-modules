variable "access_token_validity" {
  type = number
  description = "Time limit, between 5 minutes and 1 day, after which the access token is no longer valid and cannot be used."
  default = 240
}

variable "allowed_oauth_flows" {
  type = list(string)
  description = "List of allowed oauth flows. Valid values are `code`, `implicit` and `client_credentials`."
  default = []
}

variable "allowed_oauth_flows_user_pool_client" {
  type = bool
  description = "Whether the client is allowed to follow the OAuth protocol when interacting with Cognito user pools."
  default = true
}

variable "allowed_oauth_scopes" {
  type = list(string)
  description = "List of allowed OAuth scopes. Valid values are `phone`, `email`, `openid`, `profile` and `aws.cognito.signin.user.admin`."
  default = ["openid", "email"]
}

variable "callback_urls" {
  type = list(string)
  description = "List of allowed callback URLs for the identity providers."
  default = []
}

variable "default_redirect_uri" {
  type = string
  description = "Default redirect URI. Must be in the list of callback URLs."
  default = null
}

variable "enable_token_revocation" {
  type = bool
  description = "Enables or disables token revocation."
  default = true
}

variable "explicit_auth_flows" {
  type = list(string)
  description = <<-EOL
    List of authentication flows. Valid values are:
    `ADMIN_NO_SRP_AUTH`, `CUSTOM_AUTH_FLOW_ONLY`, `USER_PASSWORD_AUTH`, `ALLOW_ADMIN_USER_PASSWORD_AUTH`,
    `ALLOW_CUSTOM_AUTH`, `ALLOW_USER_PASSWORD_AUTH`, `ALLOW_USER_SRP_AUTH`, `ALLOW_REFRESH_TOKEN_AUTH`
  EOL
  default = null
}

variable "generate_secret" {
  type = bool
  description = "Should an application secret be generated."
  default = false
}

variable "id_token_validity" {
  type = number
  description = "Time limit, between 5 minutes and 1 day, after which the ID token is no longer valid and cannot be used."
  default = 240
}

variable "logout_urls" {
  type = list(string)
  description = "List of allowed logout URLs for the identity providers."
  default = []
}

variable "name" {
  type = string
  description = "Name of the application client."
}

variable "read_attributes" {
  type = list(string)
  description = "List of user pool attributes the application client can read from."
  default = null
}

variable "refresh_token_validity" {
  type = number
  description = "Time limit in days refresh tokens are valid for."
  default = 10
}

variable "supported_identity_providers" {
  type = list(string)
  description = "List of provider names for the identity providers that are supported on this client."
  default = null
}

variable "user_pool_id" {
  type = string
  description = "User pool the client belongs to."
}

variable "write_attributes" {
  type = list(string)
  description = "List of user pool attributes the application client can write to."
  default = null
}
