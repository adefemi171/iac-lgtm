resource "aws_lb_target_group" "loki" {
  name        = "${var.service_name}-tg"
  port        = var.service_port
  protocol    = "HTTP"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/ready"
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

resource "aws_lb_listener_rule" "loki" {
  listener_arn = var.alb_https_listener_arn
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.loki.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}