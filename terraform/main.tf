# Create VPC for Kubernetes Cluster. DNS hostnames must be enabled. 

resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "eks_vpc"
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
