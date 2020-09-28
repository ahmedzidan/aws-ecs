output "id" {
  value = aws_vpc.main.id
}

output "igw_id" {
  value = aws_internet_gateway.gw.id
}
