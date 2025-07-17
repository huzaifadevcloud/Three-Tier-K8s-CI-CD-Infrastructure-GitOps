output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "update_kubeconfig_cmd" {
  value = "aws eks update-kubeconfig --region=${var.aws_region} --name=${module.eks.cluster_name}"
}
