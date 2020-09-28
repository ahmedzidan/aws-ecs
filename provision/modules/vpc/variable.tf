variable "cidr" {
  description = "cidr for your vpc"
  type = string
}
variable "tags" {
  description = "tag for your vpc"
  type = map(any)
}
