resource "aws_subnet" "main" {
  vpc_id     = var.vpc_id
  cidr_block = var.cidr
  availability_zone = var.availability_zone
  tags = var.tags
}

resource "aws_route_table" "external" {
  count = var.private == true ? 0 : 1
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
}

resource "aws_route_table_association" "subnet_to_internet" {
  count = var.private == true ? 0 : 1
  subnet_id = aws_subnet.main.id
  route_table_id = aws_route_table.external[0].id
}

resource "aws_route_table" "internal" {
  count = var.private == true ? 1 : 0
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.nat_gateway_id
  }

  tags = var.tags
}

resource "aws_route_table_association" "subnet_to_nat_gateway" {
  count = var.private == true ? 1 : 0
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.internal[0].id
}
