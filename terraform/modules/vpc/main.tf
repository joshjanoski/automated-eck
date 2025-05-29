# Create VPC for Kubernetes Cluster. DNS hostnames must be enabled. 

resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc"
  }
}

# Create private subnets 1-3

resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnet_configs
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone 
  map_public_ip_on_launch = true # Assign instances in this subnet a public IP upon launch

 
  tags = {
    Name = "eks-${each.key}"
    "kubernetes.io/role/elb" = "1" # Used by Kubernetes to determine where to place external ELBs
  }

}

# Create public subnets 1-3

resource "aws_subnet" "public_subnets" {
  for_each          = var.public_subnet_configs
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone 
  map_public_ip_on_launch = true # Assign instances in this subnet a public IP upon launch

 
  tags = {
    Name = "eks-${each.key}"
    "kubernetes.io/role/elb" = "1" # Used by Kubernetes to determine where to place external ELBs
  }

}

# Create Internet Gateway

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

# Create Elastic IP for use with NAT Gateway

resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc" # Indicates that the  Elastic IP is for use with a VPC

  tags = {
    Name = "eks-nat-gateway-ip"
  }
}

# Create NAT Gateway for private subnet Internet access

resource "aws_nat_gateway" "eks_ngw" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets["public-subnet-1"].id # Assign NAT Gateway to public subnet 1. May make this a variable later.

  tags = {
    Name = "eks-nat-gateway"
  }

  depends_on = [ aws_internet_gateway.eks_igw ] # Ensures the Internet Gateway is created before the NAT Gateway
}

# Create Route Table for private subnets

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_ngw.id
  }

  tags = {
    Name = "eks-private-route"
  }
}

# Create Route Table for public subnets

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "eks-public-route"
  }
}

# Associate the Route Table with all three private subnets

resource "aws_route_table_association" "private_routes" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route.id
}

# Associate the Route Table with all three public subnets

resource "aws_route_table_association" "public_routes" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route.id
}