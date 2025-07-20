variable "aws_region" {}

variable "cluster_name" {}

variable "hosted_zone_subdomain" {}

variable "load_balancer_scheme" {
  description = "Whether the Load Balancer is internal or internet-facing (Only internal supported as of now)"
  type        = string
  default     = "internal"
  validation {
    condition     = contains(["internal"], var.load_balancer_scheme)
    error_message = "Only internal load balancer is supported."
  }
}

variable "min_task_count" {}

variable "max_task_count" {}

variable "desired_task_count" {}

variable "log_bucket_name" {}

variable "loki_image_tag" {}

variable "grafana_image_tag" {}

variable "tempo_image_tag" {}

variable "grafana_admin_user" {
  sensitive = true
}

variable "grafana_admin_password" {
  sensitive = true
}

variable "certificate_arn" {}

variable "vpc_id" {}

variable "subnet_ids" {}
