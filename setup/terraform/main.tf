# ============================================================
# Terraform main.tf — AWS EKS + ECR Infrastructure
# Movie Picture Pipeline
#
# NOTE: Designed for Udacity lab environments where:
# - Credentials used = Vocareum lab temporary credentials (with session token)
# - IAM role/user creation is blocked by SCP
# - Uses the pre-existing LabRole for EKS cluster and node group
# ============================================================

terraform {
  required_version = ">= 1.3.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ----------------------------------------------------------
# Data Sources
# NOTE: aws_availability_zones is blocked by Udacity SCP — use locals instead
# ----------------------------------------------------------

data "aws_caller_identity" "current" {}

# Look up the pre-existing LabRole (created by Udacity)
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# ----------------------------------------------------------
# Locals — hardcoded AZs (DescribeAvailabilityZones is SCP-blocked)
# ----------------------------------------------------------

locals {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
}

# ----------------------------------------------------------
# VPC & Networking
# ----------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.cluster_name}-public-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/elb"                    = "1"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.cluster_name}-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "${var.cluster_name}-rt" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ----------------------------------------------------------
# EKS Cluster — uses pre-existing LabRole (no IAM creation needed)
# ----------------------------------------------------------

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = data.aws_iam_role.lab_role.arn
  version  = "1.27"

  vpc_config {
    subnet_ids             = aws_subnet.public[*].id
    endpoint_public_access = true
  }

  tags = { Name = var.cluster_name }
}

# ----------------------------------------------------------
# EKS Node Group — also uses pre-existing LabRole
# ----------------------------------------------------------

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = data.aws_iam_role.lab_role.arn
  subnet_ids      = aws_subnet.public[*].id
  instance_types  = [var.node_instance_type]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  tags = { Name = "${var.cluster_name}-nodes" }
}

# ----------------------------------------------------------
# ECR Repositories
# ----------------------------------------------------------

resource "aws_ecr_repository" "frontend" {
  name                 = "frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Name = "frontend" }
}

resource "aws_ecr_repository" "backend" {
  name                 = "backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Name = "backend" }
}
