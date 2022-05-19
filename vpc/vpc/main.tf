/**
 *  # VPC
 *
 *  This module creates a VPC with specified CIDR and subnets.
 *  An internet gateway and routing may optionally be created, with a NAT gateway also being optional.
 *  If NAT gateway is enabled, one is created in each AZ where a public subnet exists.
 */

terraform {
  required_version = ">= 1.1.9"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.12.1"
    }
  }
}

data "aws_availability_zones" "azs" {
  state = "available"
}

locals {
  availability_zones = slice(data.aws_availability_zones.azs.names, 0, var.zone_count)
  public_subnets = { for i, cidr in var.public_subnets: cidr => element(local.availability_zones, i) }
  private_subnets = { for i, cidr in var.private_subnets: cidr => element(local.availability_zones, i) }
  subnets_by_az = {
    for az in local.availability_zones: az =>
      {
        public = [ for cidr, zone in local.public_subnets: cidr if az == zone ]
        private = [ for cidr, zone in local.private_subnets: cidr if az == zone ]
      }
  }
  public_nat_subnets = [ for az, obj in local.subnets_by_az: obj.public[0] if length(obj.public) > 0 ]
}

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = var.tags
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id = aws_vpc.this.id
  availability_zone = each.value
  cidr_block = each.key
  map_public_ip_on_launch = true
  tags = var.tags
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id = aws_vpc.this.id
  availability_zone = each.value
  cidr_block = each.key
  map_public_ip_on_launch = false
  tags = var.tags
}

# Public route table
resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.this.default_route_table_id
  tags = var.tags
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id = each.value.id
  route_table_id = aws_default_route_table.public.id
}

# Private route tables, per-AZ
resource "aws_route_table" "private" {
  for_each = toset([ for az, obj in local.subnets_by_az: az if length(obj.private) > 0 ])

  vpc_id = aws_vpc.this.id
  tags = var.tags
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id = each.value.id
  route_table_id = aws_route_table.private[each.value.availability_zone].id
}

# Internet routing
resource "aws_internet_gateway" "this" {
  count = var.create_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.this.id
  tags = var.tags
}

resource "aws_route" "internet" {
  count = var.create_internet_gateway ? 1 : 0

  route_table_id = aws_default_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.this[0].id
}

resource "aws_eip" "nat" {
  for_each = var.create_nat ? toset(local.public_nat_subnets) : []

  vpc = true
  tags = var.tags
}

resource "aws_nat_gateway" "this" {
  for_each = var.create_nat ? toset(local.public_nat_subnets) : []

  allocation_id = aws_eip.nat[each.value].id
  subnet_id = aws_subnet.public[each.value].id
  tags = var.tags
}

resource "aws_route" "nat" {
  for_each = var.create_nat ? aws_route_table.private : {}

  route_table_id = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = flatten([
    for az, obj in local.subnets_by_az: [
      for cidr, nat in aws_nat_gateway.this:
        nat.id if contains(obj.public, cidr)
    ] if az == each.key
  ])[0]
}