resource "aws_efs_file_system" "grafana_efs" {
  encrypted  = true
  kms_key_id = var.cluster_encryption_key_arn

  performance_mode                = "generalPurpose"
  throughput_mode                 = "provisioned"
  provisioned_throughput_in_mibps = 64

  tags = {
    Name          = "${var.cluster_name}-${var.service_name}-efs"
    "clusterName" = var.cluster_name
    "serviceName" = var.service_name
  }
}

resource "aws_efs_mount_target" "grafana_mount_target_a" {
  file_system_id  = aws_efs_file_system.grafana_efs.id
  subnet_id       = jsondecode(data.aws_ssm_parameter.private_subnets.value)[0]
  security_groups = [aws_security_group.grafana_efs_sg.id]
}

resource "aws_efs_mount_target" "grafana_mount_target_b" {
  file_system_id  = aws_efs_file_system.grafana_efs.id
  subnet_id       = jsondecode(data.aws_ssm_parameter.private_subnets.value)[1]
  security_groups = [aws_security_group.grafana_efs_sg.id]
}