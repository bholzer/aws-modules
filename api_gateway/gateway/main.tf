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
  lambda_routes = { for key, route in var.routes: key => route if route.type == "lambda" }

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
        }
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
}

resource "aws_apigatewayv2_route" "lambda" {
  for_each = local.lambda_routes

  api_id = aws_apigatewayv2_api.this.id
  route_key = each.key
  target = "integrations/${aws_apigatewayv2_integration.lambda[each.key].id}"
}

resource "aws_apigatewayv2_integration" "lambda" {
  for_each = local.lambda_routes

  api_id = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  integration_uri = each.value.invoke_arn
  payload_format_version = try(each.value.payload_format_version, null)
}

resource "aws_lambda_permission" "gateway" {
  for_each = toset([ for k, route in local.lambda_routes: route.function_name ])

  action = "lambda:InvokeFunction"
  function_name = each.value
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
