variable "vpc_id" {
  description = "vpc id"
  type = string
}
variable "service_name" {
  description = "service name"
  type = string
}

variable "ecs_cluster_id" {
  description = "ecs cluster id"
  type = string
}

variable "task_arn" {
  description = "task definition arn"
  type = string
}

variable "subnets_id" {
  description = "subnets for service"
  type = list(string)
}

variable "target_group_id" {
  description = "target group id for service"
  type = string
}
