resource "aws_iam_role" "loki_task_execution_role" {
  name = "sc-role-servicerole-loki-task-execution-${random_string.stack_id.result}"

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

resource "aws_iam_role_policy_attachment" "loki_task_execution_role_policy" {
  role       = aws_iam_role.loki_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "loki_cloudwatch_policy" {
  role       = aws_iam_role.loki_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy" "loki_logs_policy" {
  name = "LokiPolicy"
  role = aws_iam_role.loki_task_execution_role.id

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

resource "aws_iam_role_policy" "loki_config_policy" {
  name = "LokiConfigPolicy"
  role = aws_iam_role.loki_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter*"
        ]
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${aws_ssm_parameter.loki_config.name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "loki_efs_policy" {
  name = "LokiEFSPolicy"
  role = aws_iam_role.loki_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]
        Resource = aws_efs_file_system.loki_efs.arn
        Condition = {
          StringLike = {
            "elasticfilesystem:AccessPointArn" = aws_efs_access_point.loki_access_point.arn
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "loki_ecs_exec_policy" {
  name = "ECSExecPolicy"
  role = aws_iam_role.loki_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "loki_kms_policy" {
  name = "KMSPolicy"
  role = aws_iam_role.loki_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# resource "aws_iam_role_policy" "loki_s3_policy" {
#   name = "LokiS3BucketAccess"
#   role = aws_iam_role.loki_task_execution_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:DeleteObject",
#           "s3:ListBucket",
#           "s3:GetBucketLocation"
#         ]
#         Resource = [
#           "arn:aws:s3:::csc-observability-logs",
#           "arn:aws:s3:::csc-observability-logs/*"
#         ]
#       }
#     ]
#   })
# }