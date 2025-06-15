variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "automated-eck-on-eks-cluster"
}

variable "eks_cluster_version" {
    description = "Kubernetes version for the EKS cluster"
    type        = string
    default     = "1.33"
}

variable "eks_subnet_ids" {
  description = "List of subnet IDs (private and public) for the EKS cluster"
  type        = list(string)
}

variable "eks_vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}

variable "eks_control_plane_role_arn" {
  description = "IAM role ARN for the EKS control plane"
  type        = string
}

variable "eks_worker_role_arn" {
  description = "IAM role ARN for the EKS worker nodes"
  type        = string
}

variable "public_access_cidrs" {
  description = "The list of CIDR blocks allowed to access the EKS public API endpoint"
  type        = list(string)
  default     = [ "0.0.0.0/0" ] # This should be changed to something more restrictive 
}