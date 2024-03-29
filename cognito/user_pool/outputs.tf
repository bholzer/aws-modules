output "user_pool" {
  value = aws_cognito_user_pool.this
}

output "client" {
  value = aws_cognito_user_pool_client.this
  sensitive = true
}

output "domain" {
  value = aws_cognito_user_pool_domain.this
}