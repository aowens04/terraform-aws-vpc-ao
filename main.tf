locals {
    public_subnet_cidrs  = [for az in var.availability_zones : var.public_subnet_cidr[az].cidr_block]
    private_subnet_cidrs = [for az in var.availability_zones : var.private_subnet_cidr[az].cidr_block]
}

module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "2.64.0"

    name = var.vpc_name
    cidr = trimspace(var.vpc_cidr)
    azs = var.availability_zones
    public_subnets  = local.public_subnet_cidrs
    private_subnets = local.private_subnet_cidrs

    enable_dns_hostnames = var.enable_dns_hostnames
    enable_dns_support = var.enable_dns_support

    enable_nat_gateway = var.enable_nat_gateway
    single_nat_gateway = var.single_nat_gateway

    tags = var.tags
}