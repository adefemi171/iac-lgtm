variable "vpc_id" {}

variable "subnet_ids" {}

variable "cluster_name" {}

variable "service_name" {}

variable "service_port" {}

variable "min_task_count" {}

variable "max_task_count" {}

variable "desired_task_count" {}

variable "cluster_encryption_key_arn" {}

variable "alb_security_group_id" {}

variable "alb_https_listener_arn" {}

variable "grafana_image_tag" {}

variable "service_discovery_namespace_arn" {}

variable "loki_endpoint" {}

variable "tempo_endpoint" {}

variable "grafana_admin_user" {
  sensitive = true
}

variable "grafana_admin_password" {
  sensitive = true
}

variable "hosted_zone_subdomain" {}