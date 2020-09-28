provider "aws" {
  region = "ap-southeast-1"
  version = "~> 3.0"
}

locals {
  resource_name = "test"
  common_tags = {
    App       = "test"
    Env       = "test"
    Name      = local.resource_name
    ManagedBy = "terraform"
  }
}

terraform {
  backend "s3" {
    bucket               = "my-terrafom-bucket-name"
    region               = "ap-southeast-1"
    acl                  = "private"
    encrypt              = true
  }
}

module "vpc" {
  source = "../modules/vpc"
  cidr = "192.168.0.0/24"
  tags = local.common_tags
}

module "nat_subnet" {
  source			= "../modules/subnet"
  region			= "ap-southeast-1"
  vpc_id			= module.vpc.id
  availability_zone = "ap-southeast-1a"
  cidr = "192.168.0.224/28"
  igw_id = module.vpc.igw_id
  nat_gateway_id = "nat-0d0ab9d12a7495d93"
  private = false
  tags = local.common_tags
}
module "nat_gateway" {
  source = "../modules/nat-gateway"
  subnet_id = module.nat_subnet.subnet_id
  tags = local.common_tags
}

module "alb_subnet_a" {
  source			= "../modules/subnet"
  region			= "ap-southeast-1"
  vpc_id			= module.vpc.id
  availability_zone = "ap-southeast-1a"
  cidr = "192.168.0.240/28"
  igw_id = module.vpc.igw_id
  private = false
  tags = local.common_tags
}

module "alb_subnet_b" {
  source			= "../modules/subnet"
  region			= "ap-southeast-1"
  vpc_id			= module.vpc.id
  availability_zone = "ap-southeast-1b"
  cidr = "192.168.0.208/28"
  igw_id = module.vpc.igw_id
  private = false
  tags = local.common_tags
}


module "alb" {
  source = "../modules/alb"
  alb_name = "test-alb"
  certificate_arn = var.certificate_arn
  subnets_id = [module.alb_subnet_a.subnet_id, module.alb_subnet_b.subnet_id]
  tags = local.common_tags
  vpc_id = module.vpc.id
}

module "tg" {
  source = "../modules/target-group"
  domains_name = [var.domain_name]
  health_check_path = "/health"
  listener_arn = module.alb.listener_arn
  target_group_name = "test-test"
  vpc_id = module.vpc.id
}

module "private_subnet" {
  source = "../modules/subnet"
  availability_zone = "ap-southeast-1a"
  cidr = "192.168.0.160/28"
  igw_id = ""
  nat_gateway_id = module.nat_gateway.nat_gateway_id
  private = true
  region = "ap-southeast-1"
  tags = local.common_tags
  vpc_id = module.vpc.id
}

resource "aws_ecs_cluster" "main" {
  name = local.resource_name
}

module "ecs_task" {
  source      = "../modules/ecs-task"
  task_family = "test"
  cpu         = "256"
  memory      = "512"
  image_tag   = "v1.0.0"
  app_name    = "test"
  image_url   = var.image_url
  ecs_host_policy = file("policies/ecs-role.json")
  container_definitions = file("task-definitions/app.json")
}

module "ecs_service" {
  source = "../modules/ecs-service"
  ecs_cluster_id = aws_ecs_cluster.main.id
  service_name = "test"
  subnets_id = [module.private_subnet.subnet_id]
  target_group_id = module.tg.id
  task_arn = module.ecs_task.arn
  vpc_id = module.vpc.id
}


module "my_domain" {
  source = "../modules/route53"
  alb_dns_name = module.alb.dns_name
  alb_zone_id = module.alb.zone_id
  domain_name = var.domain_name
  zone_id = var.zone_id
}
