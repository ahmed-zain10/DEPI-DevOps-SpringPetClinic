variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1" # choose what you like
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "petclinic"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Existing EC2 key pair name for SSH"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Your IP/CIDR to allow SSH from"
  type        = string
  default     = "0.0.0.0/0" # better to change to your IP
}
