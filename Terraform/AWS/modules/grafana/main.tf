data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_secretsmanager_secret" "grafana_credentials" {
  name                    = "${var.cluster_name}-${var.service_name}-credentials-${formatdate("YYYYMMDD-hhmm", timestamp())}"
  description             = "Credentials for Grafana admin user"
  recovery_window_in_days = 0

  tags = {
    "clusterName" = var.cluster_name
    "serviceName" = var.service_name
  }
}

resource "aws_secretsmanager_secret_version" "grafana_credentials" {
  secret_id = aws_secretsmanager_secret.grafana_credentials.id
  secret_string = jsonencode({
    GF_SECURITY_ADMIN_USER     = var.grafana_admin_user
    GF_SECURITY_ADMIN_PASSWORD = var.grafana_admin_password
  })
}

resource "aws_ssm_parameter" "grafana_config" {
  name        = "/${var.cluster_name}/${var.service_name}/config"
  description = "Configuration for Grafana service"
  type        = "String"

  value = templatefile("${path.module}/grafana-config.ini", {
    hosted_zone_subdomain = var.hosted_zone_subdomain
    loki_endpoint         = var.loki_endpoint
  })

  tags = {
    "clusterName" = var.cluster_name
    "serviceName" = var.service_name
  }
}

resource "aws_appautoscaling_target" "grafana" {
  max_capacity       = var.max_task_count
  min_capacity       = var.min_task_count
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.grafana.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.grafana]
}

resource "aws_appautoscaling_policy" "grafana" {
  name               = "${var.cluster_name}-${var.service_name}-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.grafana.resource_id
  scalable_dimension = aws_appautoscaling_target.grafana.scalable_dimension
  service_namespace  = aws_appautoscaling_target.grafana.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "random_string" "stack_id" {
  length  = 8
  special = false
  upper   = false
} 