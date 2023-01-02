data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public-subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public-subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = format("%s-public-subnet-%s", var.name, count.index)
  }
}

resource "aws_route_table" "ecs-internet" {
  depends_on = [aws_vpc.main, aws_internet_gateway.main]
  vpc_id     = aws_vpc.main.id
  tags = {
    Name = "${var.name}-routing-table-public"
  }


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id

  }
}

resource "aws_route_table_association" "rt-public-subnet" {
  depends_on     = [aws_subnet.public_subnets]
  count          = length(var.public-subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.ecs-internet.id

}
