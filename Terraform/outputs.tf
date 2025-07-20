# ECS Cluster Outputs
output "observability_cluster_name" {
  description = "Name of the ECS Cluster"
  value       = aws_ecs_cluster.observability.name
}

output "cluster_encryption_key_arn" {
  description = "KMS Key for ECS Fargate encryption"
  value       = aws_kms_key.cluster_encryption.arn
}

output "service_discovery_namespace" {
  description = "Service Discovery Namespace for ECS Service Connect"
  value       = aws_service_discovery_http_namespace.observability.arn
}

# Hosted Zone Outputs
output "hosted_zone_domain_name" {
  description = "Domain name of the Hosted Zone"
  value       = aws_route53_zone.private.name
}

# Application Load Balancer Outputs
output "application_load_balancer_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.observability.arn
}

output "application_load_balancer_dns" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.observability.dns_name
}

# Loki Service Outputs
output "loki_app_endpoint" {
  description = "Endpoint URL for Loki service"
  value       = module.loki.loki_app_endpoint
}

output "loki_endpoint" {
  description = "Endpoint URL for Loki service"
  value       = module.loki.loki_endpoint
}

output "loki_service_name" {
  description = "Name of the ECS Loki Service"
  value       = module.loki.loki_service_name
}

output "loki_port" {
  description = "Port for the ECS Loki Service"
  value       = module.loki.loki_port
}

output "loki_service_connect_endpoint" {
  description = "Service Connect Discovery Endpoint for the ECS Loki Service"
  value       = module.loki.loki_service_connect_endpoint
}

output "loki_service_arn" {
  description = "ARN of the ECS Loki Service"
  value       = module.loki.loki_service_arn
}

# Grafana Service Outputs
output "grafana_app_endpoint" {
  description = "Endpoint URL for Grafana service"
  value       = module.grafana.grafana_app_endpoint
}

output "grafana_service_name" {
  description = "Name of the ECS Grafana Service"
  value       = module.grafana.grafana_service_name
}

output "grafana_port" {
  description = "Port for the ECS Grafana Service"
  value       = module.grafana.grafana_port
}

output "grafana_service_connect_endpoint" {
  description = "Service Connect Discovery Endpoint for the ECS Grafana Service"
  value       = module.grafana.grafana_service_connect_endpoint
}

output "grafana_task_security_group_id" {
  description = "Security Group ID for the ECS Grafana Service"
  value       = module.grafana.grafana_task_security_group_id
}

# Tempo Service Outputs
output "tempo_app_endpoint" {
  description = "Endpoint URL for Tempo service"
  value       = module.tempo.tempo_app_endpoint
}

output "tempo_endpoint" {
  description = "Endpoint URL for Tempo service"
  value       = module.tempo.tempo_endpoint
}

output "tempo_service_name" {
  description = "Name of the ECS Tempo Service"
  value       = module.tempo.tempo_service_name
}

output "tempo_port" {
  description = "Port for the ECS Tempo Service"
  value       = module.tempo.tempo_port
}

output "tempo_service_connect_endpoint" {
  description = "Service Connect Discovery Endpoint for the ECS Tempo Service"
  value       = module.tempo.tempo_service_connect_endpoint
}

output "tempo_service_arn" {
  description = "ARN of the ECS Tempo Service"
  value       = module.tempo.tempo_service_arn
} 