data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_ssm_parameter" "tempo_config" {
  name        = "/${var.cluster_name}/${var.service_name}/tempo/config"
  description = "Tempo Service Configuration"
  type        = "String"
  tier        = "Standard"

  value = templatefile("${path.module}/tempo-config.yaml", {
    service_port    = var.service_port
    log_bucket_name = var.log_bucket_name
    aws_region      = data.aws_region.current.name
  })

  tags = {
    "clusterName" = var.cluster_name
    "serviceName" = var.service_name
  }
}

resource "aws_appautoscaling_target" "tempo" {
  max_capacity       = var.max_task_count
  min_capacity       = var.min_task_count
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.tempo.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.tempo]
}

resource "aws_appautoscaling_policy" "tempo" {
  name               = "${var.cluster_name}-${var.service_name}-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.tempo.resource_id
  scalable_dimension = aws_appautoscaling_target.tempo.scalable_dimension
  service_namespace  = aws_appautoscaling_target.tempo.service_namespace

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