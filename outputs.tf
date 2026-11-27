output "eks_cluster_name" {
  description = "Provisioned Amazon EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "API server endpoint for the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "ecr_repository_url" {
  description = "Private Amazon ECR URL for Docker container images"
  value       = aws_ecr_repository.microservices.repository_url
}
