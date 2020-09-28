resource "aws_iam_role" "ecs_host_role" {
  name = "ecs_host_role_ip-test"
  assume_role_policy = file("policies/ecs-role.json")
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}
data "template_file" "containers" {
  template = file("task-definitions/app.json")

  vars = {
    image_tag        = var.image_tag
    image_url        = var.image_url
    app_name         = var.app_name
  }
}

resource "aws_ecs_task_definition" "main" {
  family = var.task_family
  container_definitions = data.template_file.containers.rendered
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn = aws_iam_role.ecs_host_role.arn
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  volume  {
    name = "iprice"
  }
}
