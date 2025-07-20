data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc_id
}

data "aws_ssm_parameter" "private_subnets" {
  name = var.subnet_ids
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

module "loki" {
  source = "./modules/loki"

  cluster_name                     = aws_ecs_cluster.observability.name
  service_name                     = "loki-service"
  service_port                     = 3100
  min_task_count                   = var.min_task_count
  max_task_count                   = var.max_task_count
  desired_task_count               = var.desired_task_count
  cluster_encryption_key_arn       = aws_kms_key.cluster_encryption.arn
  alb_security_group_id            = aws_security_group.alb.id
  alb_https_listener_arn           = aws_lb_listener.https.arn
  loki_image_tag                   = var.loki_image_tag
  service_discovery_namespace_arn  = aws_service_discovery_http_namespace.observability.arn
  hosted_zone_subdomain            = var.hosted_zone_subdomain
  service_discovery_namespace_name = aws_service_discovery_http_namespace.observability.name
  vpc_id                           = var.vpc_id
  subnet_ids                       = var.subnet_ids
}

module "tempo" {
  source = "./modules/tempo"

  cluster_name                     = aws_ecs_cluster.observability.name
  service_name                     = "tempo-service"
  service_port                     = 3200
  min_task_count                   = var.min_task_count
  max_task_count                   = var.max_task_count
  desired_task_count               = var.desired_task_count
  cluster_encryption_key_arn       = aws_kms_key.cluster_encryption.arn
  alb_security_group_id            = aws_security_group.alb.id
  alb_https_listener_arn           = aws_lb_listener.https.arn
  tempo_image_tag                  = var.tempo_image_tag
  service_discovery_namespace_arn  = aws_service_discovery_http_namespace.observability.arn
  log_bucket_name                  = var.log_bucket_name
  hosted_zone_subdomain            = var.hosted_zone_subdomain
  service_discovery_namespace_name = aws_service_discovery_http_namespace.observability.name
  vpc_id                           = var.vpc_id
  subnet_ids                       = var.subnet_ids
}

module "grafana" {
  source = "./modules/grafana"

  cluster_name                    = aws_ecs_cluster.observability.name
  service_name                    = "grafana-service"
  service_port                    = 3000
  min_task_count                  = var.min_task_count
  max_task_count                  = var.max_task_count
  desired_task_count              = var.desired_task_count
  cluster_encryption_key_arn      = aws_kms_key.cluster_encryption.arn
  alb_security_group_id           = aws_security_group.alb.id
  alb_https_listener_arn          = aws_lb_listener.https.arn
  grafana_image_tag               = var.grafana_image_tag
  service_discovery_namespace_arn = aws_service_discovery_http_namespace.observability.arn
  loki_endpoint                   = module.loki.loki_endpoint
  tempo_endpoint                  = module.tempo.tempo_endpoint
  grafana_admin_user              = var.grafana_admin_user
  grafana_admin_password          = var.grafana_admin_password
  hosted_zone_subdomain           = var.hosted_zone_subdomain
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.subnet_ids

  depends_on = [
    module.loki,
    module.tempo
  ]
}