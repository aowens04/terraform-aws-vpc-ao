variable "vpc_name" {
    description = "Name of VPC"
    type = string
    default = "my-vpc"
}

variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type = string
    default = "10.0.0.0/16"


}

variable "availability_zones" {
  description = "Availability zones for the VPC"
    type = list(string)
  default = ["us-west-1a", "us-west-1c"]
}

variable "public_subnet_count" {
    description = "Number of public subnets to create"
    type = number
    default = 1
}

variable "private_subnet_count" {
    description = "Number of private subnets to create"
    type = number
    default = 1
}

variable "public_subnet_cidr" {
    description = "CIDR block for the public subnet"
  type = map(object({
    cidr_block = string
  }))
  default = {
    "us-west-1a" = { cidr_block = "10.0.1.0/24" }
    "us-west-1c" = { cidr_block = "10.0.2.0/24" }
  }

  validation {
    condition     = alltrue([for az in var.availability_zones : contains(keys(var.public_subnet_cidr), az)])
    error_message = "public_subnet_cidr must include a CIDR for every availability zone in availability_zones."
  }
}


variable "private_subnet_cidr" {
    description = "CIDR block for the private subnet"
    type = map(object({
    cidr_block = string
  }))
  default = {
    "us-west-1a" = { cidr_block = "10.0.101.0/24" }
    "us-west-1c" = { cidr_block = "10.0.102.0/24" }
  }

  validation {
    condition     = alltrue([for az in var.availability_zones : contains(keys(var.private_subnet_cidr), az)])
    error_message = "private_subnet_cidr must include a CIDR for every availability zone in availability_zones."
  }
}


variable "enable_nat_gateway" {
    description = "Whether to enable the NAT gateway"
    type = bool
    default = true
}

variable "single_nat_gateway" {
    description = "Whether to use a single NAT gateway or one for each AZ"
    type = bool
    default = true
}

variable "enable_dns_hostnames" {
    description = "Whether to enable DNS hostnames for the VPC"
    type = bool
    default = true
}

variable "enable_dns_support" {
    description = "Whether to enable DNS support for the VPC"
    type = bool
    default = true
}

variable "tags" {
  description = "Resource tags"
  type = map(string)
  default = {
    Environment = "dev"
    Project = "terraform-lab"
    ManagedBy = "Terraform"
  }
}

