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

# Output keypair private key
# Download key using: terraform output -raw bastion_host_private_key_pem > bastion.key
# Restrict permissions using: chmod 400 bastion.key

output "bastion_host_private_key_pem" {
    value     = module.bastion.bastion_host_private_key_pem
    sensitive = true
}

# Output Bastion host public IP

output "bastion_host_public_ip" {
    value = module.bastion.bastion_host_public_ip
}

# Output bastion host instance ID 

output "bastion_host_instance_id" {
  value = module.bastion.bastion_host_instance_id
}