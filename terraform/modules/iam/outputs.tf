# Output ARN of EKS control plane role

output "eks_control_plane_role_arn" {
  description = "ARN of the IAM role for the EKS control plane"
  value       = aws_iam_role.eks_control_plane_role.arn
}

# Output ARN of EKS worker node role

output "eks_worker_role_arn" {
  description = "ARN of the IAM role for the EKS worker nodes"
  value       = aws_iam_role.eks_worker_role.arn
}

# Output IAM Instance Profile Name

output "iam_instance_profile_name" {
  description = "Name of IAM instance profile to attach to Bastion host"
  value       = aws_iam_instance_profile.bastion_host_instance_profile.name
}