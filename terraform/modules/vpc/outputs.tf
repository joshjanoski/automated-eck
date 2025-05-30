# Output VPC ID

output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

# Output public subnet IDs

output "public_subnet_ids" {
  value = [for s in values(aws_subnet.public_subnets) : s.id]
}

# Output private subnet IDs

output "private_subnet_ids" {
  value = [for s in values(aws_subnet.private_subnets) : s.id]
}

# Output NAT Gateway ID

output "nat_gateway_id" {
  value = aws_nat_gateway.eks_ngw.id
}

# Output Internet gateway ID

output "internet_gateway_id" {
  value = aws_internet_gateway.eks_igw.id
}