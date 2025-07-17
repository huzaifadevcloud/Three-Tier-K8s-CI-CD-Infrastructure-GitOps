aws_region = "ap-south-1"
cluster_name = "Three-Tier-K8s-EKS-Cluster"
vpc_name = "eks-vpc"
vpc_cidr = "10.0.0.0/16"
azs = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs= ["10.0.3.0/24", "10.0.4.0/24"]
