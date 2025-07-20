# Application Load Balancer
resource "aws_lb" "observability" {
  name               = "${var.cluster_name}-alb"
  internal           = var.load_balancer_scheme == "internal"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = jsondecode(data.aws_ssm_parameter.private_subnets.value)

  enable_deletion_protection = false

  tags = {
    Name = "${var.cluster_name}-alb"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.observability.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}