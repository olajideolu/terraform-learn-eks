variable cluster_name {}
variable instance_types {
  type = list(string)
  default = ["t3.medium"]
}
variable cluster_version {
  default = "1.31"
}
variable min_size {
  default = 1
}
variable max_size {
  default = 3
}
variable desired_size {
  default = 1
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.0"

  cluster_name = var.cluster_name  
  cluster_version = var.cluster_version
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    amazon-cloudwatch-observability = {
      most_recent = true
    }

  }


  subnet_ids = module.myapp-vpc.private_subnets
  vpc_id = module.myapp-vpc.vpc_id
  control_plane_subnet_ids = module.myapp-vpc.intra_subnets

  tags = {
    environment = "development"
    application = "myapp"
  }

  eks_managed_node_groups = {
    dev = {
      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      instance_types = var.instance_types
    }
  }

  enable_cluster_creator_admin_permissions = true 
  
}

resource "aws_iam_policy" "assume_grafana_role_policy" {
  name        = "AssumeGrafanaRolePolicy"
  description = "Policy to allow EKS nodes to assume the AmazonGrafanaServiceRole"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = "arn:aws:iam::015992161532:role/service-role/AmazonGrafanaServiceRole-9v1Cuvz0I"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_full_access" {
for_each = module.eks.eks_managed_node_groups
role     = each.value.iam_role_name
policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
for_each = module.eks.eks_managed_node_groups
role     = each.value.iam_role_name
policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "assume_grafana_role_attachment" {
  for_each = module.eks.eks_managed_node_groups
  role     = each.value.iam_role_name
  policy_arn = aws_iam_policy.assume_grafana_role_policy.arn
}


# Create kubeconfig file
resource "local_file" "kubeconfig" {
  depends_on = [module.eks]
  content = templatefile("${path.module}/kubeconfig.tpl", {
    cluster_name = module.eks.cluster_name
    cluster_endpoint = module.eks.cluster_endpoint
    cluster_ca_certificate = module.eks.cluster_certificate_authority_data
    cluster_token = data.aws_eks_cluster_auth.cluster.token
  })
  filename = "kubeconfig"
  file_permission = "0600"
}

# Get authentication token
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

