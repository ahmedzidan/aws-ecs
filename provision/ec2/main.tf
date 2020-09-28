provider "aws" {
  region = "ap-southeast-1"
  version = "~> 3.0"
  //shared_credentials_file =  "~/.aws/credentials"
  //profile                 = "mfa"
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
resource "aws_s3_bucket" "terraform_state" {
    bucket = "iprice-state-omsys-terraform"
    acl    = "private"
    versioning {
      enabled = true
    }
}

terraform {
  backend "s3" {
    bucket               = "iprice-state-omsys-terraform"
    region               = "ap-southeast-1"
    acl                  = "private"
    encrypt              = true
    key                  = "terraform.tfstate"
    workspace_key_prefix = "omsys/prod"
    //profile = "mfa"
  }
}


resource "aws_route_table" "external" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
}

resource "aws_subnet" "omsys" {
  vpc_id = var.vpc_id
  cidr_block = "10.0.15.0/28"
  availability_zone = var.availability_zone
  tags = local.common_tags
}

resource "aws_route_table_association" "external-main" {
  subnet_id = aws_subnet.omsys.id
  route_table_id = aws_route_table.external.id
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// load balancer
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
resource "aws_lb" "ipricegroup_production" {
  name = "ipricegroup-production"
  internal           = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.load_balancers.id]
  subnets = [aws_subnet.alb_a.id,aws_subnet.alb_b.id]
  tags = local.common_tags
}
resource "aws_lb_listener" "omsys" {
  load_balancer_arn = aws_lb.ipricegroup_production.arn
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
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ipricegroup_production.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:ap-southeast-1:976402106354:certificate/da7c82db-447b-4a0f-8483-03dd0e2d6553"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.omsys.arn
  }
}
resource "aws_lb_target_group" "omsys" {
  name     = local.resource_name
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
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
  depends_on = [aws_lb.ipricegroup_production]
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [aws_security_group.load_balancers.id]
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

resource "aws_autoscaling_group" "ecs_cluster" {
  name = local.resource_name
  min_size = 1
  max_size = 2
  desired_capacity = 2
  health_check_type = "EC2"
  target_group_arns = [aws_lb_target_group.omsys.arn]
  launch_configuration = aws_launch_configuration.ecs.name
  vpc_zone_identifier = [aws_subnet.omsys.id]
  tags = [
    {
      key                   = "Env"
      value                 = var.app_env
      propagate_at_launch   = true
    },
    {
      key                   = "App"
      value                 = var.app_name
      propagate_at_launch   = true
    },
    {
      key                   = "Name"
      value                 = local.resource_name
      propagate_at_launch   = true
    },
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "ecs" {
  name = local.resource_name
  image_id = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.ecs.id]
  iam_instance_profile = aws_iam_instance_profile.ecs.name
  key_name = var.key_name
  associate_public_ip_address = true
  user_data = "#!/bin/bash\necho ECS_CLUSTER='${local.resource_name}' > /etc/ecs/ecs.config"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "ecs_host_role" {
  name = "ecs_host_role"
  assume_role_policy = file("policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name = "ecs_instance_role_policy"
  policy = file("policies/ecs-instance-role-policy.json")
  role = aws_iam_role.ecs_host_role.id
}


resource "aws_iam_instance_profile" "ecs" {
  name = "ecs-instance-profile"
  path = "/"
  role = aws_iam_role.ecs_host_role.name
}

resource "aws_iam_role" "ecs_service_role" {
  name = "ecs_service_role"
  assume_role_policy = file("policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name = "ecs_service_role_policy"
  policy = file("policies/ecs-service-role-policy.json")
  role = aws_iam_role.ecs_service_role.id
}


resource "aws_ecs_service" "omsys" {
  name            = local.resource_name
  cluster         = aws_ecs_cluster.omsys.id
  task_definition = aws_ecs_task_definition.omsys.arn
  desired_count   = 1
  iam_role = aws_iam_role.ecs_service_role.arn
  depends_on = ["aws_iam_role_policy.ecs_service_role_policy"]
  load_balancer {
    target_group_arn = aws_lb_target_group.omsys.arn
    container_name = "nginx"
    container_port = 80
  }
}

resource "aws_ecs_task_definition" "omsys" {
  family = local.resource_name
  container_definitions = file("task-definitions/production.json")
  network_mode = "bridge"
  volume  {
      name = "iprice"
    }
}

resource "aws_route53_record" "omsys" {
  allow_overwrite = true
  name = "omsys.ipricegroup.com"
  type = "A"
  zone_id = "Z1G5RBRK5TRRQ6"
  alias {
    evaluate_target_health = false
    name = aws_lb.ipricegroup_production.dns_name
    zone_id = aws_lb.ipricegroup_production.zone_id
  }
}
