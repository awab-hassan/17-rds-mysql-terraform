variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_id" {
  description = "VPC ID for RDS security group"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block for ingress rule"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB subnet group"
  type        = list(string)
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "administrator"
}

variable "db_password" {
  description = "RDS master password — supply via terraform.tfvars (gitignored) or TF_VAR_db_password; never commit plaintext"
  type        = string
  sensitive   = true
}
