aws_region            = "us-east-1"
cluster_name          = "grafana-labs" # update name to your preference
vpc_id                = "vpc-0b6" # update VPC ID to your preference
subnet_ids            = "subnet-0c,subnet-0" # update Subnet IDs to your preference
hosted_zone_subdomain = "grafanalabs.example.com" # update to your preference
hosted_zone_id       = "Z01234567890" # update to your preference
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

certificate_arn = "arn:aws:acm-pca:us-east-1" # update to your ACM PCA ARN
