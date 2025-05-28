variable "aws_region" {
  description = "The AWS region where Kubernetes and Elasticsearch will be deployed in"
  type	      = string
  default     = "us-east-1"
}

variable "bastion_host_allowed_ip" {
  description = "The iP address allowed to SSH into the Bastion host (format: x.x.x.x/32)"
  type        = string
  default     = "0.0.0.0/0" # Defaults to open for testing, but this default needs to be removed and a user-specific single IP specified for security purposes
}