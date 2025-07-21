# Service Discovery Namespace
resource "aws_service_discovery_http_namespace" "observability" {
  name        = "iaws-ecs-${var.cluster_name}"
  description = "HTTP namespace for ECS Service Connect"

  tags = {
    "clusterName" = var.cluster_name
  }
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${var.cluster_name}-alb-sg-"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-alb-sg"
  }
}

# ALB DNS Record
resource "aws_route53_record" "alb" {
  zone_id = var.hosted_zone_id
  name    = var.hosted_zone_subdomain
  type    = "A"

  alias {
    name                   = aws_lb.observability.dns_name
    zone_id                = aws_lb.observability.zone_id
    evaluate_target_health = true
  }
}