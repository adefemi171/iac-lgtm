# ECS Task Definition
resource "aws_ecs_task_definition" "loki" {
  family                   = "${var.cluster_name}-${var.service_name}-task-definition"
  cpu                      = 4096
  memory                   = 8192
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.loki_task_execution_role.arn
  task_role_arn            = aws_iam_role.loki_task_execution_role.arn

  volume {
    name = "loki-data"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.loki_efs.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049
      authorization_config {
        access_point_id = aws_efs_access_point.loki_access_point.id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([
    {
      name              = var.service_name
      image             = "grafana/loki:${var.loki_image_tag}"
      essential         = true
      memoryReservation = 7168
      cpu               = 3584

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "ecs-loki-logs"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "loki-obs-stack"
          "awslogs-create-group"  = "true"
        }
      }

      portMappings = [
        {
          containerPort = var.service_port
          hostPort      = var.service_port
          protocol      = "tcp"
          name          = "service-port"
        }
      ]

      healthCheck = {
        command = [
          "CMD-SHELL",
          "wget -q --spider http://localhost:${var.service_port}/ready || exit 1"
        ]
        interval    = 120
        timeout     = 10
        retries     = 3
        startPeriod = 180
      }

      user = "0"

      mountPoints = [
        {
          sourceVolume  = "loki-data"
          containerPath = "/loki-data"
          readOnly      = false
        }
      ]

      secrets = [
        {
          name      = "LOKI_CONFIG_FILE"
          valueFrom = aws_ssm_parameter.loki_config.arn
        }
      ]

      entryPoint = [
        "/bin/sh",
        "-c",
        <<-EOF
          mkdir -p /etc/loki
          mkdir -p /tmp/loki/chunks
          mkdir -p /tmp/loki/boltdb-shipper-active
          mkdir -p /tmp/loki/boltdb-shipper-cache
          mkdir -p /tmp/loki/cache
          mkdir -p /tmp/loki/compactor
          mkdir -p /tmp/loki/retention
          mkdir -p /tmp/loki/rules
          mkdir -p /tmp/loki/rules-temp

          mkdir -p /loki-data/chunks
          mkdir -p /loki-data/boltdb-shipper-active
          mkdir -p /loki-data/cache
          mkdir -p /loki-data/compactor
          mkdir -p /loki-data/retention
          mkdir -p /loki-data/rules
          mkdir -p /loki-data/rules-temp

          echo "$LOKI_CONFIG_FILE" > /etc/loki/local-config.yaml

          exec /usr/bin/loki -config.file=/etc/loki/local-config.yaml -config.expand-env=true
        EOF
      ]
    }
  ])

  tags = {
    "clusterName" = var.cluster_name
    "serviceName" = var.service_name
  }
}

# ECS Service
resource "aws_ecs_service" "loki" {
  name            = var.service_name
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.loki.arn
  desired_count   = var.desired_task_count

  network_configuration {
    subnets          = split(",", var.subnet_ids)
    security_groups  = [aws_security_group.loki_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.loki.arn
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
    aws_lb_listener_rule.loki,
    aws_lb_target_group.loki
  ]

  tags = {
    "clusterName" = var.cluster_name
  }
}