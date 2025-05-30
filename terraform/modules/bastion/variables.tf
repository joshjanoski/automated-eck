variable "allowed_ips" {
  description = "The iP addresses allowed to SSH into the Bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Defaults to open for testing, but this default needs to be removed and a user-specific single IP specified for security purposes
}

variable "instance_type" {
  description = "EC2 instance type for Bastion host"
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "The ID of the VPC to associate with the Bastion host security group"
  type        = string 
}

variable subnet_id {
  description = "The public subnet where the Bastion hsot will be placed"
  type        =  string
}