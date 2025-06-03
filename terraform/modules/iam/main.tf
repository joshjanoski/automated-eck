# Create IAM role for Bastion host

resource "aws_iam_role" "bastion_host_role" {
  name = "bastionHostRole"

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
    Name = "bastion-host-role"
  }
}

# Create custom policy for eks:DescribeCluster permissions

resource "aws_iam_policy" "bastion_host_describe_cluster" {
  name        = "BastionHostDescribeCluster"
  description = "Allow EKS DescribeCluster permissions"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster"
        ],
        Resource = var.eks_cluster_arn
      }
    ]
  })
}

# Attach custom policy - BastionHostDescribeCluster to bastionHostRole

resource "aws_iam_role_policy_attachment" "bastion_host_BastionHostDescribeCluster" {
  role       = aws_iam_role.bastion_host_role.name
  policy_arn = aws_iam_policy.bastion_host_describe_cluster.arn
}

# Create instance profile and attach to Bastion host

resource "aws_iam_instance_profile" "bastion_host_instance_profile" {
  name = "BastionHostInstanceProfile"
  role = aws_iam_role.bastion_host_role.name
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