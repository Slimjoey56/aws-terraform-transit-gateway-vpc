variable "region" {
  description = "AWS Region for all resources."
  type        = string
  default     = "eu-west-1"
}

variable "first_vpc_cidr" {
  description = "CIDR block for the public VPC."
  type        = string
  default     = "10.0.0.0/24"
}

variable "second_vpc_cidr" {
  description = "CIDR block for the private VPC."
  type        = string
  default     = "20.0.0.0/24"
}

variable "admin_cidr" {
  description = "Your trusted public IPv4 CIDR for SSH, e.g. 203.0.113.10/32. Set to null to disable public SSH."
  type        = string
  default     = null
  nullable    = true
}

variable "instance_type" {
  description = "EC2 instance type used in both VPCs."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Optional existing EC2 key pair name. Prefer SSM Session Manager where possible."
  type        = string
  default     = null
  nullable    = true
}
