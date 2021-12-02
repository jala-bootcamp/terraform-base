
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/26"
  enable_dns_hostnames = true

  tags {
    description = "Custom VPC"
  }
}

resource "aws_subnet" "subnet_1_public" {
  availability_zone       = "ap-south-1a"
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/27"
  map_public_ip_on_launch = true

  tags {
    description = "Public subnet"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    description = "public route table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    description = "private route table"
  }
}

resource "aws_route" "public_gateway_access_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc_internet_gateway.id
}

resource "aws_route_table_association" "subnet_1_rt_association" {
  subnet_id      = aws_subnet.subnet_1_public.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_internet_gateway" "vpc_internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Internet gateway for the main VPC"
  }
}

resource "aws_security_group_rule" "allow_tcp_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["${var.subnet_1_public}"]
  security_group_id = aws_security_group.allow_http.id
}

resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["${var.subnet_1_public}"]
  security_group_id = aws_security_group.allow_http.id
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "HTTP traffic security group"
  }
}
