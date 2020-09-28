resource "aws_eip" "nat" {
  vpc = true
  tags = var.tags
}
resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.subnet_id
  tags = var.tags
}
