variable "name" {
  type = string
  description = "Name of the VPC"
}

variable "cidr_block" {
  type = string
  description = "The CIDR of the VPC"
}

variable "public_subnets" {
  type = list(string)
  description = "A list of CIDRs to create public subnets for"
  default = []
}

variable "private_subnets" {
  type = list(string)
  description = "A list of CIDRs to create private subnets for"
  default = []
}

variable "zone_count" {
  type = number
  description = <<-EOL
    Number of availability zones to use. Subnets are spread across them evenly.
    There should be at least as many private and public subnets as this value.
  EOL
  default = 1
}

variable "enable_dns_support" {
  type = bool
  description = "Enable DNS support for the VPC"
  default = true
}

variable "enable_dns_hostnames" {
  type = bool
  description = "Enable DNS hostnames for the VPC"
  default = true
}

variable "create_internet_gateway" {
  type = bool
  description = "Create internet gateway for VPC"
  default = true
}

variable "create_nat" {
  type = bool
  description = "Create NAT for allowing internet connectivity from private subnets"
  default = true
}

variable "tags" {
  type = map(string)
  default = {}
}