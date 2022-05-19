output "api" {
  value = aws_apigatewayv2_api.this
}

output "default_stage" {
  value = aws_apigatewayv2_stage.default
}