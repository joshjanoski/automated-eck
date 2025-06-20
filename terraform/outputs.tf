### Outputting of all these parameters in the root main.tf is not necessary, but I am doing it during development 
### for testing and troubleshooting purposes

# Output VPC ID

output "vpc_id" {
  value = module.vpc.vpc_id
}

# Output public subnet IDs

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

# Output private subnet IDs

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

# Output NAT Gateway ID

output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
}

# Output Internet gateway ID

output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}

# Output ARN of EKS control plane role

output "eks_control_plane_role_arn" {
  description = "ARN of the IAM role for the EKS control plane"
  value       = module.iam.eks_control_plane_role_arn
}

# Output ARN of EKS worker node role

output "eks_worker_role_arn" {
  description = "ARN of the IAM role for the EKS worker nodes"
  value       = module.iam.eks_worker_role_arn
}

# Output EKS cluster name

output "eks_cluster_name" {
    value = module.eks.eks_cluster_name
}

# Output EKS cluster ARN

output "eks_cluster_arn" {
    value = module.eks.eks_cluster_arn
}

# Output EKS cluster endpoint

output "eks_cluster_endpoint" {
    value = module.eks.eks_cluster_endpoint
}

# Output EKS cluster CA certificate

output "eks_cluster_ca_certificate" {
    value = module.eks.eks_cluster_ca_certificate
}

# Output the ID of the security group created automatically by EKS for the control plane

output "eks_cluster_security_group_id" {
    value = module.eks.eks_cluster_security_group_id
}