# tests/integration.tftest.hcl

run "test_vpc_creation_min_config" {
  command = apply
  
  variables {
    public_subnet_count = 1
    private_subnet_count = 1
    vpc_cidr = "10.0.0.0/16"
  }
  
  # Test CIDR is correct
  assert {
    condition     = var.vpc_cidr == "10.0.0.0/16"
    error_message = "Incorrect VPC"
  }
  
  # Test DNS hostnames
  assert {
    condition     = var.enable_dns_hostnames == true
    error_message = "DNS hostnames not enabled"
  }

  # Test DNS hostnames
  assert {
    condition     = var.enable_dns_support == true
    error_message = "DNS support not enabled"
  }
}

run "multi_az_deployment" {
  command = apply

  variables {
    availability_zones = ["us-west-1a", "us-west-1c"]
    public_subnet_count = 2
    private_subnet_count = 2
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
}

run "single_nat_gateway_configuration" {
  command = apply

  variables {
    enable_nat_gateway = true
    single_nat_gateway = true
  }

  assert {
    condition = length(module.vpc.nat_gateways) == 1
    error_message = "Expected 1 NAT gateway"
  }
}

run "multi_nat_gateway_configuration" {
  command = apply

  variables {
    enable_nat_gateway = true
    single_nat_gateway = false
  }

  assert {
    condition = length(module.vpc.nat_gateways) > 1
    error_message = "Expected multiple NAT gateways"
  }
}

run "no_nat_gateway" {
  command = apply

  variables {
    enable_nat_gateway = false
    single_nat_gateway = false
  }

  assert {
    condition = length(module.vpc.nat_gateways) == 0
    error_message = "Expected no NAT gateways"
  }
}

run "cidr_block_validation" {
  command = apply

  variables {
    vpc_cidr = "10.0.0.0.0/1"
  }

  assert {
    condition = regex("^[0-9]{1,3}\\.([0-9]{1,3}\\.){2}[0-9]{1,3}/[0-9]{1,2}$", var.vpc_cidr)
    error_message = "Invalid CIDR block"
  }
}

run "subnet_az_count_validation"{
  command = apply

  variables {
    availability_zones = ["us-west-1a", "us-west-1c"]
    public_subnet_count = 2
    private_subnet_count = 2
  }

  assert {
    condition = length(module.vpc.public_subnets) == var.public_subnet_count
    error_message = "Expected ${var.public_subnet_count} public subnets"
  }

  assert {
    condition = length(module.vpc.private_subnets) == var.private_subnet_count
    error_message = "Expected ${var.private_subnet_count} private subnets"
  }
}

