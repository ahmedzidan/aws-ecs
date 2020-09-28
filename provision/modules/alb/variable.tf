variable "alb_name" {
  description = "alb name"
  type = string
}
variable "vpc_id" {
  description = "vpc id for security group"
  type = string
}

variable "subnets_id" {
  description = "subnets ids for alb at least 2 subnet in two AZ"
  type = list(string)
}

variable "tags" {
  description = "tags for alb"
  type = map(any)
}

variable "certificate_arn" {
  description = "certificate for alb to redirect from http to https"
  type = string
}
