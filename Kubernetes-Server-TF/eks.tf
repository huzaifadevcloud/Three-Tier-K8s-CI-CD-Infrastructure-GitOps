module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true


  eks_managed_node_groups = {
    default = {
      instance_types = ["t2.medium"]
      min_size       = 2
      max_size       = 2
      desired_size   = 2
    }
  }
}
