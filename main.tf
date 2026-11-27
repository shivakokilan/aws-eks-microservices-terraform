terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.cluster_name
      Environment = "prod"
      ManagedBy   = "Terraform"
      Owner       = "Sivagnanam-Kokilan"
    }
  }
}

# 1. KMS Key for Kubernetes Secrets Envelope Encryption
resource "aws_kms_key" "eks_secrets_key" {
  description             = "KMS key for EKS Kubernetes secrets encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

# 2. Multi-AZ VPC & Subnets for EKS Cluster
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

resource "aws_subnet" "eks_private_a" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.30.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name                                          = "${var.cluster_name}-private-a"
    "kubernetes.io/cluster/${var.cluster_name}"   = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

resource "aws_subnet" "eks_private_b" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.30.2.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name                                          = "${var.cluster_name}-private-b"
    "kubernetes.io/cluster/${var.cluster_name}"   = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

# 3. IAM Role for Amazon EKS Control Plane
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-control-plane-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "://amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# 4. Amazon EKS Control Plane with Control Plane Logging & Encryption
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = [aws_subnet.eks_private_a.id, aws_subnet.eks_private_b.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_secrets_key.arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# 5. Private Amazon ECR Container Registry with Vulnerability Scanning
resource "aws_ecr_repository" "microservices" {
  name                 = "${var.cluster_name}-apps"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
