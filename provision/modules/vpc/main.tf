resource "aws_vpc" "main" {
  cidr_block                       = var.cidr
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = false
  enable_classiclink               = false
  assign_generated_ipv6_cidr_block = false
  tags = var.tags
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = var.tags
}
