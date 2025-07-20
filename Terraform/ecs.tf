# ECS Cluster
resource "aws_ecs_cluster" "observability" {
  name = var.cluster_name

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.cluster_encryption.arn
      logging    = "DEFAULT"
    }
    managed_storage_configuration {
      fargate_ephemeral_storage_kms_key_id = aws_kms_key.cluster_encryption.arn
      kms_key_id                           = aws_kms_key.cluster_encryption.arn
    }
  }

  service_connect_defaults {
    namespace = aws_service_discovery_http_namespace.observability.arn
  }
}

# Define capacity providers for the ECS cluster
resource "aws_ecs_cluster_capacity_providers" "cluster_capacity" {
  cluster_name       = aws_ecs_cluster.observability.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 2
  }
}