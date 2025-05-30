# Output EKS cluster name

output "eks_cluster_name" {
    value = aws_eks_cluster.eks_cluster.name
}

# Output EKS cluster endpoint

output "eks_cluster_endpoint" {
    value = aws_eks_cluster.eks_cluster.endpoint
}

# Output EKS cluster CA certificate

output "eks_cluster_ca_certificate" {
    value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

# Output the ID of the security group created automatically by EKS for the control plane

output "eks_cluster_security_group_id" {
    value = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}