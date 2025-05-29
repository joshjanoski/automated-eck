# Output keypair private key
# Download key using: terraform output -raw bastion_host_private_key_pem > bastion.key
# Restrict permissions using: chmod 400 bastion.key

output "bastion_host_private_key_pem" {
    value     = tls_private_key.bastion_host_key.private_key_pem
    sensitive = true
}

# Output Bastion host public IP

output "bastion_host_public_ip" {
    value = aws_instance.bastion_host.public_ip
    description = "Public IP of Bastion host"
}

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
