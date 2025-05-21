# Create VPC for Kubernetes Cluster. DNS hostnames must be enabled. 

resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc"
  }

}

# Create public subnet 1

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a" 
  map_public_ip_on_launch = true # Assign instances in this subnet a public IP upon launch

 
  tags = {
    Name = "eks-public-subnet-1"
    "kubernetes.io/role/elb" = "1" # Used by Kubernetes to determine where to place external ELBs
  }

}

# Create public subnet 2

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

   tags = {
    Name = "eks-public-subnet-2"
    "kubernetes.io/role/elb" = "1" 
  }
}

# Create private subnet 1

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" 
  
  tags = {
    Name = "eks-private-subnet-1"
    "kubernetes.io/role/internal-elb" = "1" # Used by Kubernetes to determine where to place internal ELBs
  }
}

# Create private subnet 2

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "eks-private-subnet-2"
    "kubernetes.io/role/internal-elb" = "1" 
  }
}

# Create Internet Gateway

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
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

# Associate the Route Table with both public subnets

resource "aws_route_table_association" "public_route_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "public_route_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route.id
}

# Create Elastic IP for use with NAT Gateway

resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc" # Indicates that the  Elastic IP is for use with a VPC

  tags = {
    Name = "eks-nat-gateway-ip"
  }
}

# Create a NAT Gateway so that the private subnets can get out to the Internet

resource "aws_nat_gateway" "eks_ngw" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id = aws_subnet.public_subnet_1.id

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

# Associate the Route Table with both private subnets

resource "aws_route_table_association" "private_route_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "private_route_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route.id
}