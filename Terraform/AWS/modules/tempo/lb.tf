resource "aws_lb_target_group" "tempo" {
  name        = "${var.service_name}-tg"
  port        = var.service_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
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

resource "aws_lb_listener_rule" "tempo" {
  listener_arn = var.alb_https_listener_arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tempo.arn
  }

  condition {
    path_pattern {
      values = ["/tempo*"]
    }
  }
}