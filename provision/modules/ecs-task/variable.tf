variable "task_family" {
  description = "task family name"
  type = string
}

variable "cpu" {
  description = "hom many cpu do you want to allocate for fargate"
  type = string
}
variable "memory" {
  description = "memory to be allocated to your fargate cluster"
  type = string
}
variable "image_tag" {
  description = "docker image tag"
  type = string
}

variable "app_name" {
  description = "app name"
  type = string
}

variable "image_url" {
  description = "docker image url"
  type = string
}

variable "ecs_host_policy" {
  description = "policy for ecs host"
  type = string
}

variable "container_definitions" {
  description = "ecs continer definition"
  type = string
}
