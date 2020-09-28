variable "region" {
  description = "region to provision resources on it"
  type = string
}
variable "vpc_id" {
  description = "vpc id"
  type = string
}
variable "cidr" {
  description = "cidr block for subnet"
  type = string
}
variable "tags" {
  description = "tags for vpc"
  type = map(any)
}

variable "igw_id" {
  description = "id for internet gateway"
  type = string
  default = ""
}

variable "availability_zone" {
  description = "zone for the subnet"
  type = string
}

variable "nat_gateway_id" {
  description = "nat gateway id"
  type = string
  default = ""
}

variable "private" {
  description = "specify if the subnet is private or public"
  type = bool
}
