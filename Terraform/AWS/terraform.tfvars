aws_region            = "eu-central-1"
cluster_name          = "grafana-labs"
vpc_id                = ""
subnet_ids            = ""
hosted_zone_subdomain = ""
load_balancer_scheme  = "internal"
min_task_count        = 1
max_task_count        = 2
desired_task_count    = 1
log_bucket_name       = "grafana-labs-bucket"

#Loki
loki_image_tag = "latest"

#Grafana
grafana_image_tag      = "latest"
grafana_admin_user     = "admin"
grafana_admin_password = "admin"

#Tempo
tempo_image_tag = "latest"

certificate_arn = ""
