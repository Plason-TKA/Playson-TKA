module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${var.name}-${var.env}"
  kubernetes_version = "1.31"

  endpoint_public_access = true
  endpoint_private_access = true
  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
      configuration_values = jsonencode({  
      env = {
        ENABLE_PREFIX_DELEGATION = "true"
        WARM_PREFIX_TARGET       = "1"
      }
    })
    }
  }
  access_entries = {
    main_user = {
      principal_arn = "arn:aws:iam::531148443278:user/main"  
      
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  node_security_group_additional_rules = {
    alb_to_nodes = {
      description              = "Allow ALB to communicate with worker nodes"
      protocol                 = "tcp"
      from_port                = 0
      to_port                  = 65535
      type                     = "ingress"
      source_security_group_id = aws_security_group.alb.id
    }
  }
  eks_managed_node_groups = {
    httbin = {
      instance_types = ["t3.micro"]
      ami_type       = "AL2023_x86_64_STANDARD"

      disk_size = 20

      min_size = 3
      max_size = 3
      desired_size = 3

    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 1           
      instance_metadata_tags      = "disabled"
    }
    labels = {
      role        = "general"
      environment = var.env
      nodegroup   = "${var.name}-${var.env}"
    }
    }
  }

}