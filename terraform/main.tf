# Load VPC module

module "vpc" {
  source = "./modules/vpc"
}

# Load IAM module

module "iam" {
  source     = "./modules/iam"
  eks_cluster_arn = module.eks.eks_cluster_arn
}

# Load EKS module

module "eks" {
  source     = "./modules/eks"
  eks_vpc_id = module.vpc.vpc_id
  eks_subnet_ids = concat(
    module.vpc.public_subnet_ids,
    module.vpc.private_subnet_ids
  )
  eks_control_plane_role_arn = module.iam.eks_control_plane_role_arn
  eks_worker_role_arn        = module.iam.eks_worker_role_arn
}