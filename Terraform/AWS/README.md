# Terraform Observability Stack

AWS ECS Fargate-based observability stack with Loki, Grafana, and Tempo.

## Architecture

- **ECS Fargate Cluster** with auto-scaling
- **Application Load Balancer** with HTTPS
- **Service Discovery** for inter-service communication
- **EFS** for persistent storage
- **KMS** for encryption
- **Route53** for DNS management

## Services

| Service | Port | Purpose |
|---------|------|---------|
| Loki | 3100 | Log aggregation |
| Grafana | 3000 | Visualization & dashboards |
| Tempo | 3200 | Distributed tracing |

## Quick Start

### Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- Existing VPC and subnets (referenced via SSM parameters)

### Deploy

```bash
# Initialize
terraform init

# Plan deployment
terraform plan -var-file=terraform.tfvars

# Apply
terraform apply -var-file=terraform.tfvars
```

## Modules

- `modules/loki/` - Log aggregation service
- `modules/grafana/` - Visualization platform
- `modules/tempo/` - Distributed tracing

## Outputs

Key outputs include service endpoints, cluster details, and security group IDs. Run `terraform output` to see all available outputs.

## Cleanup

```bash
terraform destroy --var-file=terraform.tfvars
```
