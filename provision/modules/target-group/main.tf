resource "aws_lb_listener_rule" "main" {
  listener_arn = var.listener_arn
  priority     = 999

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    host_header {
      values = var.domains_name
    }
  }
}

resource "aws_lb_target_group" "main" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id
  health_check {
    path = var.health_check_path
    protocol = "HTTP"
    port = "80"
    interval = 60
    healthy_threshold = 3
    unhealthy_threshold = 3
    matcher = "200"
  }
}
