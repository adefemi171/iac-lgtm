# KMS Key for cluster encryption
resource "aws_kms_key" "cluster_encryption" {
  description             = "KMS key for ECS Cluster - ${var.cluster_name}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowGenerateDataKeyAccessForFargate"
        Effect = "Allow"
        Principal = {
          Service = "fargate.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKeyWithoutPlaintext"
        ]
        Condition = {
          StringEquals = {
            "kms:EncryptionContext:aws:ecs:clusterAccount" = [data.aws_caller_identity.current.account_id]
            "kms:EncryptionContext:aws:ecs:clusterName"    = [var.cluster_name]
          }
        }
        Resource = "*"
      },
      {
        Sid    = "AllowGrantCreationPermissionForFargate"
        Effect = "Allow"
        Principal = {
          Service = "fargate.amazonaws.com"
        }
        Action = [
          "kms:CreateGrant"
        ]
        Condition = {
          StringEquals = {
            "kms:EncryptionContext:aws:ecs:clusterAccount" = [data.aws_caller_identity.current.account_id]
            "kms:EncryptionContext:aws:ecs:clusterName"    = [var.cluster_name]
          },
          ForAllValuesStringEquals = {
            "kms:GrantOperations" = ["Decrypt"]
          }
        }
        Resource = "*"
      }
    ]
  })

}