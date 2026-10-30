variable "aws_region" {
  type        = string
  description = "AWS region to deploy into."
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Name prefix used for all resources."
  default     = "terraform-jenkins"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones for the subnets (at least two, required by the ALB)."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the public subnets, one per availability zone."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the private subnets, one per availability zone."
}

variable "hosted_zone_name" {
  type        = string
  description = "Name of an existing public Route 53 hosted zone, e.g. example.com."
}

variable "jenkins_domain" {
  type        = string
  description = "Fully qualified domain name for Jenkins, e.g. jenkins.example.com."
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key used to access the Jenkins instance."
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to SSH to the Jenkins instance. Never use 0.0.0.0/0."

  validation {
    condition     = !contains(var.allowed_ssh_cidrs, "0.0.0.0/0")
    error_message = "SSH must not be open to the whole internet; use your own IP (/32)."
  }
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for Jenkins."
  default     = "t3.medium"
}
