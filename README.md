# VPC Project
## Overview
This project consists of a module to create a vpc with configurable components such as CIDR blocks, subnets, DNS support, NAT gateways, etc. This module can be incorporated as part of a larger infrastructure. This project uses AWS cloud infrastructure and is managed by Terraform HCP.

## Usage
```{code
module "terraform-aws-vpc-ao" {
  source  = "app.terraform.io/tf-vault-qa-ao/terraform-aws-vpc-ao/aws"
  version = "1.0.0"
}
```
