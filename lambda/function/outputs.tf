output "function" {
  description = "The lambda function resource"
  value = aws_lambda_function.this
}

output "deploy_policy" {
  description = "The policy used for deploying the function"
  value = aws_iam_policy.deploy
}

output "invoke_policy" {
  description = "The policy used for invoking the function"
  value = aws_iam_policy.invoke
}