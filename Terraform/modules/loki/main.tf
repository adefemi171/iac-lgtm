data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc_id
}

data "aws_ssm_parameter" "private_subnets" {
  name = var.subnet_ids
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_ssm_parameter" "loki_config" {
  name        = "/${var.cluster_name}/${var.service_name}/loki/config"
  description = "Loki Service Configuration"
  type        = "String"
  tier        = "Standard"

  value = templatefile("${path.module}/loki-config.yaml", {
    service_port = var.service_port
  })

  tags = {
    "sc:ecs:clusterName" = var.cluster_name
    "sc:ecs:serviceName" = var.service_name
  }
}

resource "aws_appautoscaling_target" "loki" {
  max_capacity       = var.max_task_count
  min_capacity       = var.min_task_count
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.loki.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.loki]
}

resource "aws_appautoscaling_policy" "loki" {
  name               = "${var.cluster_name}-${var.service_name}-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.loki.resource_id
  scalable_dimension = aws_appautoscaling_target.loki.scalable_dimension
  service_namespace  = aws_appautoscaling_target.loki.service_namespace

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