# Load VPC module

module "vpc" {
  source = "./modules/vpc"
}

# Load Bastion module

module "bastion" {
  source     = "./modules/bastion"
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0] # Pull the first subnet from the list which is public-subnet-1
}