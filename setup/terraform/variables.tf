variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "cluster"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "iam_role_arn" {
  description = "ARN of an existing IAM role to use for EKS cluster and node group. Find it with: aws iam list-roles --query 'Roles[*].[RoleName,Arn]' --output table"
  type        = string
  # No default — you MUST pass this value.
  # Example: terraform apply -var="iam_role_arn=arn:aws:iam::495022547570:role/YourRoleName"
}
