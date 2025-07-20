resource "aws_security_group" "loki_service_sg" {
  name_prefix = "${var.service_name}-sg-"
  description = "Security group for Loki service"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    from_port       = var.service_port
    to_port         = var.service_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    from_port       = 9095
    to_port         = 9095
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "clusterName" = var.cluster_name
    "serviceName" = var.service_name
  }
}

resource "aws_security_group" "loki_efs_sg" {
  name_prefix = "${var.service_name}-efs-sg-"
  description = "Security group for Loki EFS"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.loki_service_sg.id]
  }

  tags = {
    "clusterName" = var.cluster_name
    "serviceName" = var.service_name
  }
}