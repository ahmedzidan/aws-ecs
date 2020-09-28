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
