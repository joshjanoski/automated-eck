variable "vpc_cidr_block" {
    description = "CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "private_subnet_configs" {
    description = "Map of private subnet CIDR blocks and AZs"
    type = map(object({
      cidr_block        = string
      availability_zone = string
    }))
    default = {
       "private-subnet-1" = { cidr_block = "10.0.1.0/24", availability_zone = "us-east-1a" },
       "private-subnet-2" = { cidr_block = "10.0.2.0/24", availability_zone = "us-east-1b" },
       "private-subnet-3" = { cidr_block = "10.0.3.0/24", availability_zone = "us-east-1c" } 
    }
}

variable "public_subnet_configs" {
   type = map(object({
   cidr_block        = string
   availability_zone = string
   }))
   default = {
       "public-subnet-1" = { cidr_block = "10.0.4.0/24", availability_zone = "us-east-1a" },
       "public-subnet-2" = { cidr_block = "10.0.5.0/24", availability_zone = "us-east-1b" },
       "public-subnet-3" = { cidr_block = "10.0.6.0/24", availability_zone = "us-east-1c" }
  }
}
