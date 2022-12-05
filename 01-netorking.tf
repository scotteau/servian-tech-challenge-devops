################################################################################
# vpc & network
################################################################################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.default_tags, { Name = "${local.prefix}-vpc" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags, { Name = "${local.prefix}-igw" })
}

# nat gateway for private subnets
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = local.default_tags

  depends_on = [aws_internet_gateway.main]
}


data "aws_availability_zones" "available" {}

# public subnets
resource "aws_subnet" "public" {
  count                   = length(var.public)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.default_tags, {
    Name = "public-dmz-${local.azs[count.index]}",
    Type = "public"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.default_tags, { Name = "${local.prefix}-route-table-public" })
}

resource "aws_route" "main" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

# app subnet - private
resource "aws_subnet" "server" {
  count                   = length(var.servers)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.servers[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.default_tags, {
    Name = "private-app-${local.azs[count.index]}",
    Type = "private"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.default_tags, { Name = "${local.prefix}-private-route-table" })
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.nat.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "app" {
  count          = length(aws_subnet.server)
  subnet_id      = aws_subnet.server[count.index].id
  route_table_id = aws_route_table.private.id
}


# database subnet - private
resource "aws_subnet" "database" {
  count                   = length(var.database)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.database[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.default_tags, {
    Name = "private-db-${local.azs[count.index]}",
    Type = "private"
  })
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.default_tags, { Name = "${local.prefix}-route-table-database" })
}