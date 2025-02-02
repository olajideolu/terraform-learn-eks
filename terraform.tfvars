# EKS

vpc_cidr_block = "10.123.0.0/16"
private_subnet_cidr_blocks = ["10.123.3.0/24", "10.123.4.0/24"]
public_subnet_cidr_blocks = ["10.123.1.0/24", "10.123.2.0/24"]
intra_subnets_cidr_blocks = ["10.123.5.0/24", "10.123.6.0/24"]
region = "eu-central-1"
cluster_name   = "demo-cluster"
instance_types = ["t3.medium"]
cluster_version = "1.31"
min_size = 1
max_size = 3
desired_size = 2

# EC2

# # Network Configuration
# vpc_cidr         = "10.0.0.0/16"
# subnet_cidr      = "10.0.1.0/24"
# aws_region       = "eu-central-1"
# availability_zone = "eu-central-1a"

# # EC2 Instance Configuration
# instance_type = "t2.micro"
# key_name      = "deployer-key"
# ssh_key_private = "~/.ssh/id_rsa"

# # Security Group Configuration
# sg_name          = "allow_ssh_http"
# ssh_description  = "SSH from anywhere"
# http_description = "HTTP from anywhere"
# egress_from_port = 0

# # Network Ports
# ssh_port  = 22
# http_port = 80

# # CIDR and Protocol Settings
# allow_all_cidr  = "0.0.0.0/0"
# tcp_protocol    = "tcp"
# all_protocols   = "-1"

# # Resource Tags
# vpc_tags      = "main"
# subnet_tags   = "public"
# instance_tags = "web"
