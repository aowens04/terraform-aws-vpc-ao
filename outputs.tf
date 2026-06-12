output "vpc_id" {
    description = "ID of VPC"
    value = module.vpc.vpc_id
}

output "vpc_cidr" {
    description = "CIDR block for the VPC"
    value = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
    description = "IDs of the public subnets"
    value = module.vpc.public_subnets
}

output "private_subnet_ids" {
    description = "IDs of the private subnets"
    value = module.vpc.private_subnets
}

output "nat_gateway_id" {
    description = "ID of the NAT gateway"
    value = module.vpc.natgw_ids
}

output "internet_gateway_id" {
    description = "ID of the internet gateway"
    value = module.vpc.igw_id
}

output "public_route_table_ids" {
    description = "IDs of the public route tables"
    value = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
    description = "IDs of the private route tables"
    value = module.vpc.private_route_table_ids
}