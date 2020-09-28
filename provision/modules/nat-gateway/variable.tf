variable "subnet_id" {
  description = "public subnet for nat gateway"
  type = string
}

variable "tags" {
  description = "tags to be attached to nat gateway"
  type = map(any)
}
