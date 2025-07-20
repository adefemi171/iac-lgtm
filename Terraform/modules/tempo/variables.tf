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

variable "tempo_image_tag" {}

variable "service_discovery_namespace_arn" {}

variable "log_bucket_name" {}

variable "permissions_boundary_name" {}

variable "hosted_zone_subdomain" {}

variable "service_discovery_namespace_name" {} 