output "service" {
  value = aws_ecs_service.this
}

output "security_group" {
  value = try(aws_security_group.this[0], null)
}

output "autoscaling_target" {
  value = try(aws_appautoscaling_target.this[0], null)
}
