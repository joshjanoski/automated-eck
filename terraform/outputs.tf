# Output VPC ID

output "vpc_id" {
  value = module.vpc.vpc_id
}

# Output public subnet IDs

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

# Output private subnet IDs

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

# Output NAT Gateway ID

output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
}

# Output Internet gateway ID

output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}