################################################################################
# Global Varibale
################################################################################
variable "region" {
  description = "AWS Region in which you are working"
}

variable "name" {
  description = "Identifier for the application"
}

variable "environment" {
  description = "Environment"
}

variable "tags" {
  description = "Tags for the Infrastructure"
  default = {
    Owner       = "amsal"
    Environment = "dev"
  }
}

################################################################################
# VPC Varibale
################################################################################
variable "vpc_cidr" {
  description = "VPC cidr block. Example: 10.0.0.0/16"
  default     = "10.0.0.0/16"
}

variable "public_cidrs" {
  description = "Public Subnet cidr block. Example: 10.0.1.0/24 at least 3"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "private_cidrs" {
  description = "Public Subnet cidr block. Example: 10.0.3.0/24 at least 3"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

################################################################################
# Kubernetes Varibale
################################################################################

variable "cluster_version" {
  description = "Version for kubernetes cluster"
}

variable "disk_size" {
  description = "Disk size for node instances in node group"
  type = number
  
  default = 12
}

variable "instance_type" {
  description = "Type of instance for node group"
  type = list(string)
  
  default = ["t3.small"]
}

variable "replicas" {
  description = "Replicas in Cluster"
  type = number
  
  default = 2
}

variable "desired_size" {
  description = "Desired capacity for nodes"
  type = number
  
  default = 2
}

variable "max_size" {
  description = "Max capacity for nodes"
  type = number
  
  default = 3
}

variable "min_size" {
  description = "Min capacity for nodes"
  type = number
  
  default = 1
}

variable "image" {
  description = "ECR image URI for Kubernetes"
  type = string
  
}

variable "pod_port" {
  description = "Port for container"
  type = number
  
}
