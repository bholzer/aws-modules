/**
 *  # Cognito User Pool
 *
 *  Creates a Cognito user pool, client, and domain
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

resource "aws_cognito_user_pool" "this" {
  name = var.name
}

resource "aws_cognito_user_pool_client" "this" {
  name = var.name

  user_pool_id = aws_cognito_user_pool.this.id
  callback_urls = var.callback_urls
  allowed_oauth_flows = var.allowed_oauth_flows
  allowed_oauth_scopes = var.allowed_oauth_scopes
  allowed_oauth_flows_user_pool_client = var.allowed_oauth_flows_user_pool_client
  supported_identity_providers = var.supported_identity_providers
}

resource "aws_cognito_user_pool_domain" "this" {
  domain = var.name
  user_pool_id = aws_cognito_user_pool.this.id
}
