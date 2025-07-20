output "grafana_app_endpoint" {
  description = "Endpoint URL for Grafana service"
  value       = "https://${var.hosted_zone_subdomain}/grafana"
}

output "grafana_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.grafana.name
}

output "grafana_port" {
  description = "Port on which Grafana service is listening"
  value       = var.service_port
}

output "grafana_service_arn" {
  description = "ARN of the Grafana service"
  value       = aws_ecs_service.grafana.id
}

output "grafana_service_connect_endpoint" {
  description = "Service Discovery endpoint on which other services can connect to this service using Service Connect"
  value       = "${aws_ecs_service.grafana.name}:${var.service_port}"
}

output "grafana_task_security_group_id" {
  description = "Security group for the Grafana service"
  value       = aws_security_group.grafana_service_sg.id
}

output "grafana_efs_file_system_id" {
  description = "ID of the EFS file system for Grafana"
  value       = aws_efs_file_system.grafana_efs.id
}

output "grafana_target_group_arn" {
  description = "ARN of the ALB target group for Grafana"
  value       = aws_lb_target_group.grafana.arn
}

output "grafana_task_definition_arn" {
  description = "ARN of the ECS task definition for Grafana"
  value       = aws_ecs_task_definition.grafana.arn
}

output "grafana_execution_role_arn" {
  description = "ARN of the IAM execution role for Grafana"
  value       = aws_iam_role.grafana_task_execution_role.arn
}

output "grafana_credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret for Grafana credentials"
  value       = aws_secretsmanager_secret.grafana_credentials.arn
} 