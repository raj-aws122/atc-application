# Configure AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create an EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn
  version  = "1.24" # Choose a supported Kubernetes version
}

# Create an IAM Role for EKS
resource "aws_iam_role" "eks_role" {
  name = "eks-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
  })
}

# Create an IAM Role for Node Instances
resource "aws_iam_role" "node_instance_role" {
  name = "node-instance-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
  })
}

# Attach necessary IAM policies to the Node Instance Role
resource "aws_iam_role_policy_attachment" "node_instance_role_policy_attachment" {
    role       = aws_iam_role.node_instance_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Create an EKS Node Group
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_role_arn   = aws_iam_role.node_instance_role.arn
  node_group_name = "my-node-group"
  subnet_ids      = data.aws_subnet_ids.selected.ids
  instance_types = ["t2.medium"]
  desired_capacity = 1
  min_size = 1
  max_size = 1
}

# Get available subnets
data "aws_subnet_ids" "selected" {
  vpc_id = "vpc-xxxxxxxxx"
}