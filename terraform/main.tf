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
  subnet_id     = aws_subnet.public_subnet_1.id

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

# Create security group for Kubernetes (EKS) worker nodes

resource "aws_security_group" "eks_node_sg" {
  name        = "eks_node_sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.eks_vpc.id

    # Allow node-to-node communication within this security group
    ingress {
      description     = "Allow all traffic within the eks_node_sg security group"
      from_port       = 0 # Since all protocols are allowed from and to ports can be set to 0
      to_port         = 0
      protocol        = "-1" # Allow all protocols
      self            = true # Could also specify this as security_groups = [aws_security_group.eks_node_sg.id] 
    }

    # Allow HTTPS traffic from the EKS control plane (replace CIDR with control plane security groups or IPs later)
    ingress {
      description   = "Allow HTTPS traffic from the EKS control plane"
      from_port     = 443
      to_port       = 443
      protocol      = "tcp"
      cidr_blocks   = ["0.0.0.0/0"] # Narrow this later
    }
 
    # Allow all outbound traffic
    egress {
      description   = "Allow all outbound traffic for worker nodes"
      from_port     = 0
      to_port       = 0
      protocol      = "-1" 
      cidr_blocks   =  ["0.0.0.0/0"] 
    }

  tags = {
    Name = "eks-node-sg"
  }
}

# Create IAM role for EKS control plane so that it can manage the cluster 

resource "aws_iam_role" "eks_control_plane_role" {
  name = "eksControlPlaneRole"

  assume_role_policy  = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole" # Allow EKS service to assume this role
      }
    ]
  })

  tags = {
    Name = "eks-control-plane-role"
  }
}

# Attach managed policy - AmazonEKSClusterPolicy to eksControlPlaneRole

resource "aws_iam_role_policy_attachment" "eks_control_plane_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_control_plane_role.name 
}

# Create IAM role for EKS worker nodes

resource "aws_iam_role" "eks_worker_role" {
  name = "eksWorkerRole"

  assume_role_policy  = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole" # Allow EC2 service to assume this role
      }
    ]
  })

  tags = {
    Name = "eks-worker-role"
  }
}

# Attach managed policy - AmazonEKSWorkerNodePolicy to eksWorkerRole

resource "aws_iam_role_policy_attachment" "eks_worker_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_role.name
}

# Attach managed policy - AmazonEC2ContainerRegistryReadOnly to eksWorkerRole (for read-only access to Amazon Elastic Container Registry (ECR))

resource "aws_iam_role_policy_attachment" "eks_worker_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_role.name
}

# Attach managed policy - AmazonEKS_CNI_Policy to eksWorkerRole (for Amazon VPC CNI plugin that manages pod networking)

resource "aws_iam_role_policy_attachment" "eks_worker_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_role.name
}



