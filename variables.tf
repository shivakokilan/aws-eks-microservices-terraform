variable "aws_region" {
  description = "Primary AWS region for EKS cluster deployment"
  type        = string
  default     = "me-central-1" # UAE (Dubai) Region
}

variable "cluster_name" {
  description = "Name of the Amazon EKS cluster"
  type        = string
  default     = "enterprise-eks-prod"
}

variable "kubernetes_version" {
  description = "Kubernetes control plane version"
  type        = string
  default     = "1.30"
}

variable "vpc_cidr" {
  description = "CIDR block for the dedicated EKS VPC"
  type        = string
  default     = "10.30.0.0/16"
}

variable "node_instance_types" {
  description = "EC2 instance types for the EKS managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}
