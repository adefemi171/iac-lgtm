# Application Load Balancer Target Group
resource "aws_lb_target_group" "grafana" {
  name        = "${var.service_name}-tg"
  port        = var.service_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/grafana/api/health"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    "clusterName" = var.cluster_name
    "serviceName" = var.service_name
  }
}

# ALB Listener Rule
resource "aws_lb_listener_rule" "grafana" {
  listener_arn = var.alb_https_listener_arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }

  condition {
    path_pattern {
      values = ["/grafana*"]
    }
  }
}