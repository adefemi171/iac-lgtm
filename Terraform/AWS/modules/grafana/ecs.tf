resource "aws_ecs_service" "grafana" {
  name            = var.service_name
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.desired_task_count

  network_configuration {
    subnets          = split(",", var.subnet_ids)
    security_groups  = [aws_security_group.grafana_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana.arn
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
    aws_lb_listener_rule.grafana,
    aws_lb_target_group.grafana
  ]

  tags = {
    "clusterName" = var.cluster_name
  }
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "${var.cluster_name}-${var.service_name}-task-definition"
  cpu                      = 2048
  memory                   = 4096
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.grafana_task_execution_role.arn
  task_role_arn            = aws_iam_role.grafana_task_execution_role.arn

  volume {
    name = "grafana-storage"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.grafana_efs.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049
      authorization_config {
        iam = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = "grafana/grafana:${var.grafana_image_tag}"
      essential = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "ecs-grafana-logs"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "grafana-stack"
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
          "wget -q --spider http://localhost:${var.service_port}/grafana/api/health || exit 1"
        ]
        interval    = 60
        timeout     = 10
        retries     = 5
        startPeriod = 30
      }

      mountPoints = [
        {
          sourceVolume  = "grafana-storage"
          containerPath = "/var/lib/grafana"
          readOnly      = false
        }
      ]

      user = "0"

      environment = [
        {
          name  = "GF_SERVER_ROOT_URL"
          value = "https://${var.hosted_zone_subdomain}/grafana"
        },
        {
          name  = "GF_SERVER_SERVE_FROM_SUB_PATH"
          value = "true"
        },
        {
          name  = "GF_DATABASE_TYPE"
          value = "sqlite3"
        },
        {
          name  = "GF_DATABASE_PATH"
          value = "/var/lib/grafana/grafana.db"
        },
        {
          name  = "GF_DATABASE_WAL"
          value = "true"
        },
        {
          name  = "GF_PATHS_DATA"
          value = "/var/lib/grafana"
        },
        {
          name  = "GF_PATHS_LOGS"
          value = "/var/log/grafana"
        },
        {
          name  = "GF_PATHS_PLUGINS"
          value = "/var/lib/grafana/plugins"
        },
        {
          name  = "GF_PATHS_PROVISIONING"
          value = "/etc/grafana/provisioning"
        },
        {
          name  = "GF_AUTH_ANONYMOUS_ENABLED"
          value = "true"
        },
        {
          name  = "GF_AUTH_ANONYMOUS_ORG_ROLE"
          value = "Viewer"
        },
        {
          name  = "GF_LOG_MODE"
          value = "console"
        },
        {
          name  = "GF_LOG_LEVEL"
          value = "info"
        },
        {
          name  = "LOKI_URL"
          value = var.loki_endpoint
        },
        {
          name  = "TEMPO_URL"
          value = var.tempo_endpoint
        }
      ]

      secrets = [
        {
          name      = "GF_SECURITY_ADMIN_USER"
          valueFrom = "${aws_secretsmanager_secret.grafana_credentials.arn}:GF_SECURITY_ADMIN_USER::"
        },
        {
          name      = "GF_SECURITY_ADMIN_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.grafana_credentials.arn}:GF_SECURITY_ADMIN_PASSWORD::"
        },
        {
          name      = "GRAFANA_CONFIG"
          valueFrom = aws_ssm_parameter.grafana_config.arn
        }
      ]

      entryPoint = [
        "/bin/sh",
        "-c",
        <<-EOF
          # Install sqlite3 first
          apk add --no-cache sqlite
          
          # Create a backup directory if it doesn't exist
          mkdir -p /var/lib/grafana/backups
          
          # If database exists, check for locks and corruption
          if [ -f /var/lib/grafana/grafana.db ]; then
            echo "Database exists, checking for locks and corruption..."
            
            # Create a backup
            cp /var/lib/grafana/grafana.db /var/lib/grafana/backups/grafana.db.backup.$(date +%Y%m%d%H%M%S)
            
            # Check for corruption - try to run a simple query
            if ! sqlite3 /var/lib/grafana/grafana.db "PRAGMA integrity_check;" 2>/dev/null; then
              echo "Database appears to be corrupted, recreating..."
              
              # Remove all database files including journal and WAL files
              rm -f /var/lib/grafana/grafana.db*
              
              # Create a fresh empty database
              echo "Creating fresh database..."
              touch /var/lib/grafana/grafana.db
              sqlite3 /var/lib/grafana/grafana.db "PRAGMA journal_mode=WAL; PRAGMA synchronous=NORMAL; PRAGMA busy_timeout=5000;" 2>/dev/null
              
              # Set proper permissions
              chmod 664 /var/lib/grafana/grafana.db
              chown 472:472 /var/lib/grafana/grafana.db
              
              # Also set permissions on WAL and SHM files if they exist
              [ -f /var/lib/grafana/grafana.db-wal ] && chmod 664 /var/lib/grafana/grafana.db-wal && chown 472:472 /var/lib/grafana/grafana.db-wal
              [ -f /var/lib/grafana/grafana.db-shm ] && chmod 664 /var/lib/grafana/grafana.db-shm && chown 472:472 /var/lib/grafana/grafana.db-shm
              
              echo "Database has been recreated"
            else
              echo "Database appears to be healthy"
            fi
          else
            echo "Database does not exist, creating new one..."
            # Create a fresh empty database
            touch /var/lib/grafana/grafana.db
            sqlite3 /var/lib/grafana/grafana.db "PRAGMA journal_mode=WAL; PRAGMA synchronous=NORMAL; PRAGMA busy_timeout=5000;" 2>/dev/null
            chmod 664 /var/lib/grafana/grafana.db
            chown 472:472 /var/lib/grafana/grafana.db
          fi
          
          # Set proper permissions on the entire data directory
          echo "Setting proper permissions on data directory..."
          find /var/lib/grafana -type d -exec chmod 775 {} \;
          find /var/lib/grafana -type f -exec chmod 664 {} \;
          chown -R 472:472 /var/lib/grafana

          mkdir -p /etc/grafana/provisioning/datasources
          mkdir -p /var/lib/grafana/plugins
          mkdir -p /usr/share/grafana/plugins-bundled
          echo "$GRAFANA_CONFIG" > /etc/grafana/grafana.ini
          
          # Create Loki datasource configuration
          cat > /etc/grafana/provisioning/datasources/loki.yaml << 'EOF_LOKI'
          apiVersion: 1
          datasources:
            - name: Loki
              type: loki
              access: proxy
              url: ${var.loki_endpoint}
              jsonData:
                maxLines: 1000
              editable: true
          EOF_LOKI

          # Create Tempo datasource configuration
          cat > /etc/grafana/provisioning/datasources/tempo.yaml << 'EOF_TEMPO'
          apiVersion: 1
          datasources:
            - name: Tempo
              type: tempo
              access: proxy
              url: ${var.tempo_endpoint}
              basicAuth: false
              jsonData:
                maxLines: 1000
              editable: true
          EOF_TEMPO

          # Start Grafana
          /run.sh
        EOF
      ]
    }
  ])

  depends_on = [
    aws_efs_mount_target.grafana_mount_target_a,
    aws_efs_mount_target.grafana_mount_target_b
  ]

  tags = {
    "clusterName" = var.cluster_name
    "serviceName" = var.service_name
  }
}