variable "vpc_id" {
  description = "vpc id for tg"
  type = string
}
variable "listener_arn" {
  description = "default alb listener arn"
  type = string
}

variable "domains_name" {
  description = "domains name to be served from the tg"
  type = list(string)
}

variable "target_group_name" {
  description = "target group name"
  type = string
}

variable "health_check_path" {
  description = "the path for the target group to check the health"
  type = string
}
