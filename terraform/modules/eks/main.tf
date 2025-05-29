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

# Create EKS Cluster

resource "aws_eks_cluster" "eks_cluster" {
  name     = "automated-eck-on-eks-cluster"
  role_arn = aws_iam_role.eks_control_plane_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnet_1.id,
      aws_subnet.public_subnet_2.id,
      aws_subnet.public_subnet_3.id,
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id,
      aws_subnet.private_subnet_3.id
    ]
    endpoint_public_access  = false
    endpoint_private_access = true # API access to cluster is only available internally through Bastion host
  }

  depends_on = [ aws_iam_role_policy_attachment.eks_control_plane_AmazonEKSClusterPolicy ] # Make sure policy is attached to role before creating cluster
}

# Create Node Group for Worker Nodes

resource "aws_eks_node_group" "eks_worker_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "automated-eck-on-eks-worker-node-group"
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
    aws_subnet.private_subnet_3.id
  ]
  scaling_config {
    desired_size = 3 #Provision 3 nodes to start
    max_size     = 6
    min_size     = 1
  }

  instance_types = ["t3.small"]
  ami_type       = "AL2_x86_64" # Amazon Linux 2

  depends_on = [ 
    aws_iam_role_policy_attachment.eks_worker_AmazonEKSWorkerNodePolicy, # Make sure all policies are attached to role before creating worker nodes
    aws_iam_role_policy_attachment.eks_worker_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_worker_AmazonEC2ContainerRegistryReadOnly
  ]
}