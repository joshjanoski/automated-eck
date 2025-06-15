# Create security group for Kubernetes (EKS) worker nodes

resource "aws_security_group" "eks_node_sg" {
  name        = "eks_node_sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.eks_vpc_id

    # Allow node-to-node communication within this security group
    ingress {
      description     = "Allow all traffic within the eks_node_sg security group"
      from_port       = 0 # Since all protocols are allowed from and to ports can be set to 0
      to_port         = 0
      protocol        = "-1" # Allow all protocols
      self            = true # Could also specify this as security_groups = [aws_security_group.eks_node_sg.id] 
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

# Create EKS Cluster

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = var.eks_control_plane_role_arn
  version  = var.eks_cluster_version

  vpc_config {
    subnet_ids = var.eks_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs     = var.public_access_cidrs
  }
}

# Create Node Group for Worker Nodes

resource "aws_eks_node_group" "eks_worker_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "automated-eck-on-eks-worker-node-group"
  node_role_arn   = var.eks_worker_role_arn
  subnet_ids      = var.eks_subnet_ids
  scaling_config {
    desired_size = 3 #Provision 3 nodes to start
    max_size     = 6
    min_size     = 1
  }

  instance_types = ["t3.small"]
  ami_type       = "AL2023_x86_64_STANDARD" # Amazon Linux 2023
}