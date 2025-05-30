# Load VPC module

module "vpc" {
  source = "./modules/vpc"
}

# Load Bastion module

module "bastion" {
  source     = "./modules/bastion"
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0] # Pull the first subnet from the list which is public-subnet-1
  eks_cluster_security_group_id   = module.eks.eks_cluster_security_group_id
}

# Load IAM module

module "iam" {
  source     = "./modules/iam"
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
  eks_worker_role_arn = module.iam.eks_worker_role_arn
}