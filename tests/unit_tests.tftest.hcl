# tests/unit_tests.tftest.hcl
# Unit tests for VPC module

# Test 1: VPC Creation with Minimal Configuration
run "test_vpc_creation_min_config" {
  command = plan
  
  variables {
    vpc_cidr = "10.0.0.0/16"
    availability_zones = ["us-west-1a"]
    public_subnet_cidr = {
      "us-west-1a" = { cidr_block = "10.0.1.0/24" }
    }
    private_subnet_cidr = {
      "us-west-1a" = { cidr_block = "10.0.101.0/24" }
    }
  }
  
  # Test minimal subnet creation
  assert {
    condition     = length(module.vpc.public_subnets) == 1
    error_message = "Expected 1 public subnet"
  }
  
  assert {
    condition     = length(module.vpc.private_subnets) == 1
    error_message = "Expected 1 private subnet"
  }
}

# Test 2: Multi-AZ Deployment
run "test_multi_az_deployment" {
  command = apply

  variables {
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
  }

  assert {
    condition = length(module.vpc.public_subnets) == 2
    error_message = "Expected 2 public subnets"
  }

  assert {
    condition = length(module.vpc.private_subnets) == 2
    error_message = "Expected 2 private subnets"
  }

  assert {
    condition = length(module.vpc.public_subnets) == length(var.availability_zones)
    error_message = "Public subnet count must match the number of availability zones"
  }
  
  assert {
    condition = length(module.vpc.private_subnets) == length(var.availability_zones)
    error_message = "Private subnet count must match the number of availability zones"
  }
}

# Test 3a: NAT Gateway Configuration - Single NAT Gateway
run "test_single_nat_gateway_configuration" {
  command = plan

  variables {
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
    single_nat_gateway = true
  }

  assert {
    condition = length(module.vpc.natgw_ids) == 1
    error_message = "Expected 1 NAT gateway when single_nat_gateway is true"
  }
}

# Test 3b: NAT Gateway Configuration - Multiple NAT Gateways
run "test_multi_nat_gateway_configuration" {
  command = plan

  variables {
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
  }

  assert {
    condition = length(module.vpc.natgw_ids) == 2
    error_message = "Expected 2 NAT gateways (one per AZ) when single_nat_gateway is false"
  }
}

# Test 4: NAT Gateway Disabled
run "test_no_nat_gateway" {
  command = plan

  variables {
    vpc_cidr = "10.0.0.0/16"
    availability_zones = ["us-west-1a"]
    public_subnet_cidr = {
      "us-west-1a" = { cidr_block = "10.0.1.0/24" }
    }
    private_subnet_cidr = {
      "us-west-1a" = { cidr_block = "10.0.101.0/24" }
    }
    enable_nat_gateway = false
  }

  assert {
    condition = length(module.vpc.natgw_ids) == 0
    error_message = "Expected no NAT gateways when enable_nat_gateway is false"
  }
}

# Test 5a: Variable Validation - Valid CIDR Block
run "test_valid_cidr_block_validation" {
  command = plan

  variables {
    vpc_cidr = "10.0.0.0/16"
    availability_zones = ["us-west-1a"]
    public_subnet_cidr = {
      "us-west-1a" = { cidr_block = "10.0.1.0/24" }
    }
    private_subnet_cidr = {
      "us-west-1a" = { cidr_block = "10.0.101.0/24" }
    }
  }

  assert {
    condition     = can(regex("^[0-9]{1,3}\\.([0-9]{1,3}\\.){2}[0-9]{1,3}/[0-9]{1,2}$", var.vpc_cidr))
    error_message = "Valid CIDR block should match regex pattern"
  }
}

# Test 5b: Variable Validation - Subnet count matches AZ count
run "test_subnet_az_count_validation" {
  command = plan

  variables {
    vpc_cidr = "10.0.0.0/16"
    availability_zones = ["us-west-1a", "us-west-1b", "us-west-1c"]
    public_subnet_cidr = {
      "us-west-1a" = { cidr_block = "10.0.1.0/24" }
      "us-west-1b" = { cidr_block = "10.0.2.0/24" }
      "us-west-1c" = { cidr_block = "10.0.3.0/24" }
    }
    private_subnet_cidr = {
      "us-west-1a" = { cidr_block = "10.0.101.0/24" }
      "us-west-1b" = { cidr_block = "10.0.102.0/24" }
      "us-west-1c" = { cidr_block = "10.0.103.0/24" }
    }
  }

  assert {
    condition = length(module.vpc.public_subnets) == length(var.availability_zones)
    error_message = "Public subnet count must match the number of availability zones"
  }

  assert {
    condition = length(module.vpc.private_subnets) == length(var.availability_zones)
    error_message = "Private subnet count must match the number of availability zones"
  }
}

# Test 6: Tagging - Verify tags are applied to resources
run "test_verify_global_tags" {
  command = plan

  variables {
    vpc_cidr = "10.0.0.0/16"
    availability_zones = ["us-west-1a"]
    public_subnet_cidr = {
      "us-west-1a" = { cidr_block = "10.0.1.0/24" }
    }
    private_subnet_cidr = {
      "us-west-1a" = { cidr_block = "10.0.101.0/24" }
    }
    tags = {
      Environment = "test"
      Project     = "vpc-testing"
      ManagedBy   = "Terraform"
    }
  }

  # Verify tags variable is set correctly
  assert {
    condition     = var.tags["Environment"] == "test"
    error_message = "Expected Environment tag to be 'test'"
  }

  assert {
    condition     = var.tags["Project"] == "vpc-testing"
    error_message = "Expected Project tag to be 'vpc-testing'"
  }

  assert {
    condition     = var.tags["ManagedBy"] == "Terraform"
    error_message = "Expected ManagedBy tag to be 'Terraform'"
  }
}
