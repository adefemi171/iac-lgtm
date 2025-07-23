# IaC-LGT: Multi-Cloud Observability Stack

Minimal infrastructure-as-code templates for deploying Loki, Grafana, and Tempo on AWS, Azure, and locally.

## Top-level directory layout

```table
📂IAC-LGT
├── 📂AWS-IAC
│   ├── 📂CloudFormation
│   │   └── 📜README.md
│   └── 📂SAM
│       └── 📜README.md
├── 📂Azure-IAC
│   ├── 📂ARM
│   │   └── 📜README.md
│   └── 📂Bicep
│       └── 📜README.md
├── 📂Local
│   ├── 📜docker-compose.yml
│   ├── 📜README.md
│   ├── 📜send-test-logs.sh
│   ├── 📜send-test-traces.sh
│   ├── 📜setup-volumes-simple.sh
│   ├── 📜.gitignore
│   ├── 📂config
│   │   ├── 📂grafana
│   │   │   ├── 📜grafana.ini
│   │   │   └── 📂provisioning
│   │   │       └── 📂datasources
│   │   │           └── 📜datasources.yaml
│   │   ├── 📂loki
│   │   │   └── 📜loki-config.yaml
│   │   └── 📂tempo
│   │       └── 📜tempo-config.yaml
│   └── 📂images
│       ├── 📜log_sample.png
│       └── 📜traces_sample.png
├── 📂Terraform
│   ├── 📜.gitignore
│   ├── 📂AWS
│   │   ├── 📜main.tf
│   │   ├── 📜variables.tf
│   │   ├── 📜outputs.tf
│   │   ├── 📜provider.tf
│   │   ├── 📜network.tf
│   │   ├── 📜lb.tf
│   │   ├── 📜kms.tf
│   │   ├── 📜ecs.tf
│   │   ├── 📜terraform.tfvars
│   │   ├── 📜README.md
│   │   └── 📂modules
│   │       ├── 📂grafana
│   │       │   ├── 📜main.tf
│   │       │   ├── 📜variables.tf
│   │       │   ├── 📜outputs.tf
│   │       │   ├── 📜ecs.tf
│   │       │   ├── 📜efs.tf
│   │       │   ├── 📜sg.tf
│   │       │   ├── 📜lb.tf
│   │       │   ├── 📜role.tf
│   │       │   └── 📜grafana-config.ini
│   │       ├── 📂loki
│   │       │   ├── 📜main.tf
│   │       │   ├── 📜variables.tf
│   │       │   ├── 📜outputs.tf
│   │       │   ├── 📜ecs.tf
│   │       │   ├── 📜efs.tf
│   │       │   ├── 📜sg.tf
│   │       │   ├── 📜lb.tf
│   │       │   ├── 📜role.tf
│   │       │   └── 📜loki-config.yaml
│   │       └── 📂tempo
│   │           ├── 📜main.tf
│   │           ├── 📜variables.tf
│   │           ├── 📜outputs.tf
│   │           ├── 📜ecs.tf
│   │           ├── 📜sg.tf
│   │           ├── 📜lb.tf
│   │           ├── 📜role.tf
│   │           └── 📜tempo-config.yaml
│   ├── 📂GCP
│   │   └── 📜README.md
│   └── 📂Azure
│       └── 📜README.md
├── 📜LICENSE
└── 📜README.md
```

## Overview

- **AWS-IAC/**: AWS infrastructure templates using SAM (Serverless Application Model) and CloudFormation for deploying Loki, Grafana, and Tempo LGT stack on ECS Fargate with Application Load Balancer, EFS storage, and KMS encryption.

- **Azure-IAC/**: Azure infrastructure templates using Bicep and ARM (Azure Resource Manager) for deploying the LGT stack on Azure Container Apps with Virtual Network, Storage Accounts, Key Vault, and Application Gateway.

- **Terraform/**: Multi-cloud Terraform modules for AWS, GCP, and Azure with modular architecture for Loki, Grafana, and Tempo services including networking, storage, and security configurations.

- **Local/**: Docker Compose configuration for local development environment with Grafana, Loki, and Tempo containers, including sample data scripts, volume management and data sources.
