# Lookup latest Ubuntu 22.04 Amazon Machine Image (AMI) to install on Bastion host

data "aws_ami" "ubuntu_latest" {
    most_recent = true

    filter {
        name    = "name"
        values  = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]

    }

    filter {
        name    = "virtualization-type"
        values  = ["hvm"] # Only retrieve Hardware Virtual Machine (HVM) images
    }

    owners = ["099720109477"] # Canonical (official Ubuntu publisher)
}

# Create private key used for Bastion host keypair generation

resource "tls_private_key" "bastion_host_key" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

# Create AWS keypair used for EC2 Bastion host

resource "aws_key_pair" "bastion_host_key_pair" {
    key_name   = "eks-bastion-host-key"
    public_key = tls_private_key.bastion_host_key.public_key_openssh # Uses public key generated from the TLS private key resource
}

# Create security group for Bastion host

resource "aws_security_group" "bastion_host_sg" {
    name        = "bastion-host-sg"
    description = "Security group for Bastion host"
    vpc_id = var.vpc_id

    ingress {
        description = "Allow SSH to Bastion host from user-defined IP"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.allowed_ips # IPs specified in variables.tf
    }

    egress {
        description = "Allow all outbound traffic from Bastion host"
        from_port   = 0 # Since all protocols are allowed from and to ports can be set to 0
        to_port     = 0
        protocol    = "-1" # Allow all protocols
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "bastion-host-sg"
    }
}

# Create security group rule to allow any host in the Bastion host security group access to ping and communciate with the EKS worker nodes

resource "aws_security_group_rule" "bastion_to_worker_nodes_sg_rule" {
  description              = "Allow Bastion host to communicate with EKS worker nodes"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = var.eks_cluster_security_group_id
  source_security_group_id = aws_security_group.bastion_host_sg.id
}

# Create Bastion host EC2 instance 

resource "aws_instance" "bastion_host" {
    ami                         = data.aws_ami.ubuntu_latest.id
    instance_type               = var.instance_type
    iam_instance_profile        = var.iam_instance_profile_name
    subnet_id                   = var.subnet_id
    vpc_security_group_ids      = [aws_security_group.bastion_host_sg.id]
    key_name                    = aws_key_pair.bastion_host_key_pair.key_name
    associate_public_ip_address = true
    user_data = file("${path.module}/bastion_setup.sh")

    tags = {
        Name = "eks-bastion-host"
    } 
}
