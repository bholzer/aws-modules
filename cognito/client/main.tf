/**
 *  # Cognito App Client
 *
 *  Creates a Cognito app client in a user pool.
 */

terraform {
  required_version = ">= 1.1.9"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.12.1"
    }
  }

  backend "s3" {}
}

resource "aws_cognito_user_pool_client" "this" {
  name = var.name

  user_pool_id = var.user_pool_id
  access_token_validity = var.access_token_validity
  allowed_oauth_flows_user_pool_client = var.allowed_oauth_flows_user_pool_client
  allowed_oauth_flows = var.allowed_oauth_flows
  allowed_oauth_scopes = var.allowed_oauth_scopes
  callback_urls = var.callback_urls
  default_redirect_uri = var.default_redirect_uri
  enable_token_revocation = var.enable_token_revocation
  explicit_auth_flows = var.explicit_auth_flows
  generate_secret = var.generate_secret
  id_token_validity = var.id_token_validity
  logout_urls = var.logout_urls
  read_attributes = var.read_attributes
  refresh_token_validity = var.refresh_token_validity
  supported_identity_providers = var.supported_identity_providers
  write_attributes = var.write_attributes
}
