/**
 *  # API Gateway
 *
 *  Creates an API Gateway with routes and their integrations
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

locals {
  lambda_routes = {
    for key, route in var.routes:
      key => merge(
        route,
        { auth_enabled = length(try(route.auth, {})) > 0 }
      )
    if route.type == "lambda"
  }

  s3_routes = {
    for key, route in var.routes:
      "${replace(key, "//$/", "")}/{proxy+}" => route if route.type == "s3" 
  }

  sqs_routes = {
    for key, route in var.routes:
      key => merge(
        route,
        {
          request_parameters = merge(
            { MessageBody = "$request.body.message" },
            try(route.request_parameters, {}),
            { QueueUrl = route.queue_url }
          )
        },
        { auth_enabled = length(try(route.auth, {})) > 0 }
      ) if route.type == "sqs"
  }
}

resource "aws_apigatewayv2_api" "this" {
  name = var.name
  protocol_type = "HTTP"
  description = var.description

  tags = var.tags
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.this.id
  name = "$default"
  auto_deploy = var.auto_deploy
  tags = var.tags

  default_route_settings {
    throttling_burst_limit = var.default_throttling_burst_limit
    throttling_rate_limit = var.default_throttling_rate_limit
  }
}

data "aws_lambda_function" "lambda" {
  for_each = toset([for key, route in local.lambda_routes: route.function_name])
  function_name = each.value
}

resource "aws_apigatewayv2_route" "lambda" {
  for_each = local.lambda_routes

  api_id = aws_apigatewayv2_api.this.id
  route_key = each.key
  target = "integrations/${aws_apigatewayv2_integration.lambda[each.key].id}"
  authorizer_id = each.value.auth_enabled ? aws_apigatewayv2_authorizer.this[each.key].id : null
  authorization_type = each.value.auth_enabled ? "JWT" : null
  authorization_scopes = each.value.auth_enabled ? try(each.value.auth.scopes, null) : null
}

resource "aws_apigatewayv2_integration" "lambda" {
  for_each = local.lambda_routes

  api_id = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  integration_uri = data.aws_lambda_function.lambda[each.value.function_name].invoke_arn
  payload_format_version = try(each.value.payload_format_version, null)
}

resource "aws_lambda_permission" "gateway" {
  for_each = local.lambda_routes

  action = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = join("/", [aws_apigatewayv2_api.this.execution_arn, "*", "*"])
}

resource "aws_apigatewayv2_route" "s3" {
  for_each = local.s3_routes

  api_id = aws_apigatewayv2_api.this.id
  route_key = each.key
  target = "integrations/${aws_apigatewayv2_integration.s3[each.key].id}"
}

resource "aws_apigatewayv2_integration" "s3" {
  for_each = local.s3_routes

  api_id = aws_apigatewayv2_api.this.id
  integration_type = "HTTP_PROXY"
  integration_method = "GET"
  integration_uri = "${each.value.bucket_url}/{proxy}"
}

resource "aws_apigatewayv2_route" "sqs" {
  for_each = local.sqs_routes

  api_id = aws_apigatewayv2_api.this.id
  route_key = each.key
  target = "integrations/${aws_apigatewayv2_integration.sqs[each.key].id}"
  authorizer_id = each.value.auth_enabled ? aws_apigatewayv2_authorizer.this[each.key].id : null
  authorization_type = each.value.auth_enabled ? "JWT" : null
  authorization_scopes = each.value.auth_enabled ? try(each.value.auth.scopes, null) : null
}

resource "aws_apigatewayv2_integration" "sqs" {
  for_each = local.sqs_routes

  api_id = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_subtype = "SQS-SendMessage"
  integration_method = "POST"
  integration_uri = each.value.arn
  request_parameters = each.value.request_parameters
}

resource "aws_apigatewayv2_authorizer" "this" {
  for_each = { for key, route in merge(local.lambda_routes, local.sqs_routes): key => route if route.auth_enabled }

  name = replace(each.key, "/[^a-zA-Z0-9._-]+/", "-") 
  api_id = aws_apigatewayv2_api.this.id
  authorizer_type = "JWT"
  identity_sources = [ each.value.auth.source ]

  jwt_configuration {
    audience = each.value.auth.audience
    issuer = each.value.auth.issuer
  }
}


