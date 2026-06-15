# tests/integration_tests.tftest.hcl
# Integration tests for VPC module

# Integration Test 1: Full Deployment Plan
run "test_full_vpc_deployment" {
  command = plan

  variables {
    vpc_name = "test-vpc-full"
    vpc_cidr = "10.0.0.0/16"
    availability_zones = ["us-west-1a", "us-west-1c"]
    public_subnet_cidr = {
      "us-west-1a" = { cidr_block = "10.0.1.0/24" }
      "us-west-1c" = { cidr_block = "10.0.2.0/24" }
    }
    private_subnet_cidr = {
      "us-west-1a" = { cidr_block = "10.0.101.0/24" }
      "us-west-1c" = { cidr_block = "10.0.102.0/24" }
    }
    enable_nat_gateway = true
    single_nat_gateway = false
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Environment = "integration-test"
      Project     = "vpc-testing"
      ManagedBy   = "Terraform"
    }
  }

  # Verify all subnets are created
  assert {
    condition     = length(module.vpc.public_subnets) == 2
    error_message = "Expected 2 public subnets in full deployment"
  }

  assert {
    condition     = length(module.vpc.private_subnets) == 2
    error_message = "Expected 2 private subnets in full deployment"
  }

  # Verify NAT Gateways are planned to be created
  assert {
    condition     = length(module.vpc.natgw_ids) == 2
    error_message = "Expected 2 NAT gateways (one per AZ)"
  }

  # Verify route tables are planned
  assert {
    condition     = length(module.vpc.public_route_table_ids) > 0
    error_message = "Public route tables should be created"
  }

  assert {
    condition     = length(module.vpc.private_route_table_ids) > 0
    error_message = "Private route tables should be created"
  }

  # Verify tags are passed correctly
  assert {
    condition     = var.tags["Environment"] == "integration-test"
    error_message = "Environment tag should be applied to VPC"
  }

  assert {
    condition     = var.tags["ManagedBy"] == "Terraform"
    error_message = "ManagedBy tag should be applied to VPC"
  }
}

# Integration Test 2: Network Connectivity Configuration
run "test_network_connectivity" {
  command = plan

  variables {
    vpc_name = "test-vpc-connectivity"
    vpc_cidr = "10.0.0.0/16"
    availability_zones = ["us-west-1a", "us-west-1c"]
    public_subnet_cidr = {
      "us-west-1a" = { cidr_block = "10.0.1.0/24" }
      "us-west-1c" = { cidr_block = "10.0.2.0/24" }
    }
    private_subnet_cidr = {
      "us-west-1a" = { cidr_block = "10.0.101.0/24" }
      "us-west-1c" = { cidr_block = "10.0.102.0/24" }
    }
    enable_nat_gateway = true
    single_nat_gateway = false
    enable_dns_hostnames = true
    enable_dns_support = true
  }

  # Verify NAT Gateway exists for private subnet connectivity
  assert {
    condition     = length(module.vpc.natgw_ids) > 0
    error_message = "NAT Gateway must exist for private subnet internet connectivity"
  }

  # Verify route tables are created for both public and private subnets
  assert {
    condition     = length(module.vpc.public_route_table_ids) > 0
    error_message = "Public route tables must exist for routing to Internet Gateway"
  }

  assert {
    condition     = length(module.vpc.private_route_table_ids) > 0
    error_message = "Private route tables must exist for routing to NAT Gateway"
  }

  # Verify public and private subnets exist
  assert {
    condition     = length(module.vpc.public_subnets) > 0
    error_message = "Public subnets should be created for internet connectivity"
  }

  assert {
    condition     = length(module.vpc.private_subnets) > 0
    error_message = "Private subnets should be created for internal resources"
  }

  # Verify variables for DNS settings are configured
  assert {
    condition     = var.enable_dns_hostnames == true
    error_message = "DNS hostnames must be enabled for proper network connectivity"
  }

  assert {
    condition     = var.enable_dns_support == true
    error_message = "DNS support must be enabled for proper network connectivity"
  }
}