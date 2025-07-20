output "tempo_app_endpoint" {
  description = "Endpoint URL for Tempo App"
  value       = "https://${var.hosted_zone_subdomain}/tempo"
}

output "tempo_endpoint" {
  description = "Endpoint URL for Tempo"
  value       = "http://${var.service_name}.${var.service_discovery_namespace_name}:${var.service_port}/tempo"
}

output "tempo_service_name" {
  description = "Name of the Tempo service"
  value       = aws_ecs_service.tempo.name
}

output "tempo_port" {
  description = "Port for the Tempo service"
  value       = var.service_port
}

output "tempo_service_arn" {
  description = "ARN of the Tempo service"
  value       = aws_ecs_service.tempo.id
}

output "tempo_service_connect_endpoint" {
  description = "Service Discovery endpoint on which other services can connect to this service using Service Connect"
  value       = "${aws_ecs_service.tempo.name}:${var.service_port}"
}

output "tempo_task_security_group_id" {
  description = "Security group for the Tempo task"
  value       = aws_security_group.tempo_service_sg.id
}

output "tempo_target_group_arn" {
  description = "ARN of the ALB target group for Tempo"
  value       = aws_lb_target_group.tempo.arn
}

output "tempo_task_definition_arn" {
  description = "ARN of the ECS task definition for Tempo"
  value       = aws_ecs_task_definition.tempo.arn
}

output "tempo_execution_role_arn" {
  description = "ARN of the IAM execution role for Tempo"
  value       = aws_iam_role.tempo_execution_role.arn
} 