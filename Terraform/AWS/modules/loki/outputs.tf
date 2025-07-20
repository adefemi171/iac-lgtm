output "loki_app_endpoint" {
  description = "Endpoint URL for Loki App"
  value       = "https://${var.hosted_zone_subdomain}/loki/api/v1/push"
}

output "loki_endpoint" {
  description = "Endpoint URL for Loki service"
  value       = "http://${var.service_name}.${var.service_discovery_namespace_name}:${var.service_port}/loki/api/v1/push"
}

output "loki_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.loki.name
}

output "loki_port" {
  description = "Port on which Loki service is listening"
  value       = var.service_port
}

output "loki_service_arn" {
  description = "ARN of the Loki service"
  value       = aws_ecs_service.loki.id
}

output "loki_service_connect_endpoint" {
  description = "Service Discovery endpoint on which other services can connect to this service using Service Connect"
  value       = "${aws_ecs_service.loki.name}:${var.service_port}"
}

output "loki_task_security_group_id" {
  description = "Security group for the Loki service"
  value       = aws_security_group.loki_service_sg.id
}

output "loki_efs_file_system_id" {
  description = "ID of the EFS file system for Loki"
  value       = aws_efs_file_system.loki_efs.id
}

output "loki_efs_access_point_id" {
  description = "ID of the EFS access point for Loki"
  value       = aws_efs_access_point.loki_access_point.id
}

output "loki_target_group_arn" {
  description = "ARN of the ALB target group for Loki"
  value       = aws_lb_target_group.loki.arn
}

output "loki_task_definition_arn" {
  description = "ARN of the ECS task definition for Loki"
  value       = aws_ecs_task_definition.loki.arn
}

output "loki_execution_role_arn" {
  description = "ARN of the IAM execution role for Loki"
  value       = aws_iam_role.loki_task_execution_role.arn
} 