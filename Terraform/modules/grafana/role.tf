resource "aws_iam_role" "grafana_task_execution_role" {
  name = "grafana-task-execution-${random_string.stack_id.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    "clusterName" = var.cluster_name
    "serviceName" = var.service_name
  }
}

resource "aws_iam_role_policy_attachment" "grafana_task_execution_role_policy" {
  role       = aws_iam_role.grafana_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "grafana_cloudwatch_policy" {
  role       = aws_iam_role.grafana_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy" "grafana_logs_policy" {
  name = "GrafanaPolicy"
  role = aws_iam_role.grafana_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.cluster_name}/${var.service_name}*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "grafana_config_policy" {
  name = "GrafanaConfigPolicy"
  role = aws_iam_role.grafana_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter*",
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "aws_secretsmanager_secret.grafana_credentials.arn",
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${aws_ssm_parameter.grafana_config.name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "grafana_efs_policy" {
  name = "GrafanaEFSPolicy"
  role = aws_iam_role.grafana_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ]
        Resource = aws_efs_file_system.grafana_efs.arn
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Name" = "${var.cluster_name}-${var.service_name}-efs"
          }
        }
      }
    ]
  })
}