resource "aws_security_group" "ecs_service" {
  name = var.service_name
  description = "Allows all traffic"
  vpc_id = var.vpc_id
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "main" {
  name            = var.service_name
  cluster         = var.ecs_cluster_id
  task_definition = var.task_arn
  desired_count   = 1
  launch_type = "FARGATE"
  force_new_deployment = true
  network_configuration {
    subnets = var.subnets_id
    security_groups = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = var.target_group_id
    container_name   = "nginx"
    container_port   = "80"
  }
}
