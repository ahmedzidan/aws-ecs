provider "aws" {
  region = var.region
  version = "~> 3.0"
  shared_credentials_file =  "~/.aws/credentials"
  profile                 = "mfa"
}

locals {
  resource_name = "${var.resource_prefix}-${var.app_env}-${var.app_name}"
  common_tags = {
    App       = var.app_name
    Env       = var.app_env
    Name      = local.resource_name
    ManagedBy = "terraform"
  }
}

terraform {
  backend "s3" {
    bucket               = "iprice-state-omsys-terraform"
    region               = "ap-southeast-1"
    acl                  = "private"
    encrypt              = true
    key                  = "terraform.tfstate"
    workspace_key_prefix = "omsys/qa-${var.app_version}"
    profile = "mfa"
    shared_credentials_file = "~/.aws/credentials"
  }
}

data "terraform_remote_state" "shared_resources" {
  backend = "s3"
  config = {
    bucket = "iprice-states-terraform"
    key = "iprice-shared-resources/terraform.tfstate"
    region = var.region
    profile = "mfa"
    shared_credentials_file = "~/.aws/credentials"
  }
}

resource "aws_route_table" "external" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
}
###############################
## private subnet
################################
resource "aws_subnet" "omsys_private" {
  vpc_id = var.vpc_id
  cidr_block = "10.0.15.0/28"
  availability_zone = var.availability_zone
  tags = local.common_tags
}
resource "aws_route_table_association" "shared_routing_table_with_private_subnet_a" {
  subnet_id      = aws_subnet.omsys_private.id
  route_table_id = data.terraform_remote_state.shared_resources.outputs.route_table_to_nat_a_id
}
########################################################################################################################
## load balancer
########################################################################################################################
resource "aws_subnet" "alb_a" {
  vpc_id = var.vpc_id
  cidr_block = "10.0.7.16/28"
  availability_zone = "ap-southeast-1a"
  tags = local.common_tags
}
resource "aws_route_table_association" "alb_subnet_a" {
  subnet_id = aws_subnet.alb_a.id
  route_table_id = aws_route_table.external.id
}
resource "aws_subnet" "alb_b" {
  vpc_id = var.vpc_id
  cidr_block = "10.0.7.32/28"
  availability_zone = "ap-southeast-1b"
  tags = local.common_tags
}
resource "aws_route_table_association" "alb_subnet_b" {
  subnet_id = aws_subnet.alb_b.id
  route_table_id = aws_route_table.external.id
}

resource "aws_security_group" "load_balancers" {
  name = "omsys_load_balancers"
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
resource "aws_lb" "iprice_mx" {
  name = "iprice-mx"
  internal           = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.load_balancers.id]
  subnets = [aws_subnet.alb_a.id,aws_subnet.alb_b.id]
  tags = local.common_tags
}
resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_lb.iprice_mx.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "iprice_mx" {
  load_balancer_arn = aws_lb.iprice_mx.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:ap-southeast-1:976402106354:certificate/cb8c339b-a34e-436a-a76d-fb4afcfa49dc"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Hello this is me 'application load balancer' and iam serving multiple domains"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "omsys_host_qa" {
  listener_arn = aws_lb_listener.iprice_mx.arn
  priority     = 999

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.omsys.arn
  }

  condition {
    host_header {
      values = ["${var.app_version}-${var.app_name}.iprice.mx"]
    }
  }
}

resource "aws_lb_target_group" "omsys" {
  name     = "${local.resource_name}-${var.app_version}"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id
  health_check {
    path = "/health-check"
    protocol = "HTTP"
    port = "80"
    interval = 60
    healthy_threshold = 3
    unhealthy_threshold = 3
    matcher = "200"
  }
  depends_on = [aws_lb.iprice_mx]
}

########################################################################################################################
## ecs cluster
########################################################################################################################
resource "aws_security_group" "ecs" {
  name = local.resource_name
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

resource "aws_ecs_cluster" "omsys" {
  name = local.resource_name
}

resource "aws_iam_role" "ecs_host_role" {
  name = "ecs_host_role"
  assume_role_policy = file("policies/ecs-role.json")
}

########################################################################################################################
## ecs service and task
########################################################################################################################
resource "aws_ecs_service" "omsys" {
  name            = local.resource_name
  cluster         = aws_ecs_cluster.omsys.id
  task_definition = aws_ecs_task_definition.omsys.arn
  desired_count   = 1
  launch_type = "FARGATE"
  network_configuration {
    subnets = [aws_subnet.alb_a.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.omsys.id
    container_name   = "nginx"
    container_port   = "80"
  }
}

data "template_file" "containers" {
  template = file("task-definitions/production.json")

  vars = {
    image_tag        = "${var.app_version}-${var.app_env}"
  }
}
data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}
resource "aws_ecs_task_definition" "omsys" {
  family = local.resource_name
  container_definitions = data.template_file.containers.rendered
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  task_role_arn = aws_iam_role.ecs_host_role.arn
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  volume  {
      name = "iprice"
    }
}
########################################################################################################################
## route53
########################################################################################################################
resource "aws_route53_record" "omsys" {
  allow_overwrite = true
  name = "${var.app_version}-${var.app_name}.iprice.mx"
  type = "A"
  zone_id = "Z1KC542MKS61W2"
  alias {
    evaluate_target_health = false
    name = aws_lb.iprice_mx.dns_name
    zone_id = aws_lb.iprice_mx.zone_id
  }
}
