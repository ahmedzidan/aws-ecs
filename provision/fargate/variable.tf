variable "zone_id" {
  description = "route53 zone id"
  type = string
}
variable "domain_name" {
  description = "your domain or subdomin name"
  type = string
}

variable "image_url" {
  description = "docker image url"
  type = string
}

variable "certificate_arn" {
  description = "ssl certificate arn from certificate manager"
  type = string
}
