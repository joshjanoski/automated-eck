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

# Output bastion host instance ID 

output "bastion_host_instance_id" {
  description = "ID of Bastion host"
  value       = aws_instance.bastion_host.id
}