variable "ecs_cluster_name" {
  description = "ecs cluster name"
  type = string
  default = "omsys_cluster"
}

variable "vpc_id" {
  description = "iprice vpc id"
  type = string
  default = "vpc-2205f647"
}

variable "region" {
  description = "region to have this resources"
  type = string
  default = "ap-southeast-1"
}
variable "ami" {
  description = "ecs optimized ami"
  type = string
  default = "ami-003cb73efe1eb03cc"
}

variable "key_name" {
  description = "key pair for qa environment"
  type = string
  default = "iprice-qa-ec2-2019.pem.pub"
}

variable "availability_zone" {
  description = "zone for the subnet"
  type = string
  default = "ap-southeast-1a"
}

variable "igw_id" {
  description = "iprice vpc internet gateway id"
  type = string
  default = "igw-77957812"
}

variable "app_name" {
  description = "app name"
  type = string
  default = "omsys"
}

variable "resource_prefix" {
  description = "resource prefix"
  type = string
  default = "iprice"
}

variable "instance_type" {
  description = "instance type"
  type = string
  default = "t3a.micro"
}

variable "iamge_url" {
  description = "docker image tag"
  type = string
  default = "976402106354.dkr.ecr.ap-southeast-1.amazonaws.com/omsys/nginx"
}
variable "image_tag" {
  description = "docker image tag"
  type = string
  default = "v1.0.9-production"
}

variable "app_env" {
  description = "app environment"
  type = string
  default = "qa"
}

variable "app_version" {
  description = "app version"
  type = string
  default = "ip-ecs-cluster-1"
}
