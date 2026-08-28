output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "ecr_registry" {
  description = "ECR registry URL (account.dkr.ecr.region.amazonaws.com)"
  value       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

output "frontend_ecr_repo_url" {
  description = "Full ECR URL for the frontend repository"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_ecr_repo_url" {
  description = "Full ECR URL for the backend repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_ecr_repo_name" {
  description = "ECR repository name for frontend"
  value       = aws_ecr_repository.frontend.name
}

output "backend_ecr_repo_name" {
  description = "ECR repository name for backend"
  value       = aws_ecr_repository.backend.name
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "lab_role_arn" {
  description = "ARN of the LabRole used by EKS and GitHub Actions"
  value       = data.aws_iam_role.lab_role.arn
}
