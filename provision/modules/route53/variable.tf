variable "domain_name" {
  description = "domain name to be created in route53"
  type = string
}
variable "zone_id" {
  description = "zone id for the domain to be created under it"
  type = string
}
variable "alb_dns_name" {
  description = "load balancer dns name"
  type = string
}
variable "alb_zone_id" {
  description = "load balancer zone id"
  type = string
}
