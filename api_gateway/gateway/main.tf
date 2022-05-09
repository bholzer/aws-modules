terraform {
  required_version = ">= 1.1.9"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.12.1"
    }
  }
}

locals {
  lambda_routes = {
    for key, route in var.routes:
      key => merge(
        { payload_format_version = "2.0" },
        route,
        { has_jwt = length(try(route.jwt, {})) > 0 }
      ) if route.type == "lambda"
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
            { body = "$request.body" },
            try(route.request_parameters, {})
          )
          has_jwt = length(try(route.jwt, {})) > 0
        }
      )
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
}

resource "aws_apigatewayv2_authorizer" "jwt" {
  for_each = {  }
}

resource "aws_apigatewayv2_route" "lambda" {
  for_each = local.lambda_routes

  api_id = aws_apigatewayv2_api.this.id
  route_key = each.key

  authorization_type = each.value.has_jwt ? "JWT" : null
  authorization_scopes = each.value.has_jwt ? try(each.value.jwt.authorization_scopes, null) : null
}
