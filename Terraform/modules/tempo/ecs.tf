resource "aws_ecs_task_definition" "tempo" {
  family                   = "${var.cluster_name}-${var.service_name}-task-definition"
  cpu                      = 4096
  memory                   = 8192
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.tempo_execution_role.arn
  task_role_arn            = aws_iam_role.tempo_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = var.service_name
      image = "bitnami/grafana-tempo:${var.tempo_image_tag}"

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "ecs-tempo-logs"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "tempo-obs-stack"
          "awslogs-create-group"  = "true"
        }
      }

      portMappings = [
        {
          containerPort = var.service_port
          hostPort      = var.service_port
          protocol      = "tcp"
          name          = "service-port"
        },
        {
          containerPort = 4317
          hostPort      = 4317
          protocol      = "tcp"
          name          = "otlp-grpc"
        },
        {
          containerPort = 4318
          hostPort      = 4318
          protocol      = "tcp"
          name          = "otlp-http"
        }
      ]

      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost:${var.service_port}/ready || exit 1"
        ]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 180
      }

      user = "0"

      environment = [
        {
          name  = "AWS_REGION"
          value = data.aws_region.current.name
        },
        {
          name  = "ServicePort"
          value = tostring(var.service_port)
        },
        {
          name  = "TEMPO_SERVER_HTTP_LISTEN_PORT"
          value = tostring(var.service_port)
        },
        {
          name  = "TEMPO_LOG_LEVEL"
          value = "debug"
        },
        {
          name  = "TEMPO_BUCKET_NAME"
          value = var.log_bucket_name
        }
      ]

      secrets = [
        {
          name      = "TEMPO_CONFIG_FILE"
          valueFrom = aws_ssm_parameter.tempo_config.arn
        }
      ]

      entryPoint = [
        "/bin/sh",
        "-c",
        <<-EOF
          apt-get update && apt-get install -y curl
          echo "Starting Tempo with configuration from SSM Parameter Store"
          mkdir -p /etc/tempo
          mkdir -p /var/tempo/traces
          mkdir -p /var/tempo/generator/wal

          echo "$TEMPO_CONFIG_FILE" > /etc/tempo/tempo-config.yaml
          /opt/bitnami/grafana-tempo/bin/tempo -config.file /etc/tempo/tempo-config.yaml
        EOF
      ]
    }
  ])

  tags = {
    "clusterName" = var.cluster_name
    "serviceName" = var.service_name
  }
}

resource "aws_ecs_service" "tempo" {
  name            = var.service_name
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.tempo.arn
  desired_count   = var.desired_task_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = jsondecode(data.aws_ssm_parameter.private_subnets.value)
    security_groups  = [aws_security_group.tempo_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tempo.arn
    container_name   = var.service_name
    container_port   = var.service_port
  }

  service_connect_configuration {
    enabled   = true
    namespace = var.service_discovery_namespace_arn

    service {
      port_name      = "service-port"
      discovery_name = var.service_name
      client_alias {
        port     = var.service_port
        dns_name = var.service_name
      }
    }
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  enable_execute_command = true

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 2
  }

  depends_on = [
    aws_lb_listener_rule.tempo,
    aws_lb_target_group.tempo
  ]

  tags = {
    "clusterName" = var.cluster_name
  }
}