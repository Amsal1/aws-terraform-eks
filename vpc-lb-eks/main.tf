locals {
  environment = var.environment
  name        = "${var.name}-${var.environment}"
  region      = var.region
  tags        = var.tags
}

provider "aws" {
  region = local.region
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = var.vpc_cidr

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = var.private_cidrs
  public_subnets  = var.public_cidrs
  enable_ipv6 = true

  # Single NAT Gateway
  enable_nat_gateway = true
  enable_vpn_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  tags = {
  Terraform = "true"
  Environment = "dev"
  }

  public_subnet_tags = {
  "kubernetes.io/role/internal-elb" = "1"
  }

  private_subnet_tags = {
  "kubernetes.io/cluster/${var.name}" = "shared"
  }

}

################################################################################
# EKS Module
################################################################################

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.name
  cluster_version = var.cluster_version
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    disk_size      = var.disk_size
    instance_types = var.instance_type
    
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    first = {
      create_launch_template = false
      launch_template_name   = ""
      
      # Remote access cannot be specified with a launch template
      /*remote_access = {
        ec2_ssh_key               = "amsal_ttn"
        #source_security_group_ids = [aws_security_group.remote_access.id]
      }*/
      
      desired_size = var.desired_size
      max_size =  var.max_size
      min_size = var.min_size
      #instance_types = ["t3.small"]
    }
  }
}

resource "null_resource" "java"{
  depends_on = [module.eks]
  provisioner "local-exec" {
    command = "aws eks  update-kubeconfig --name $AWS_CLUSTER_NAME"
    environment = {
      AWS_CLUSTER_NAME = var.name
    }
  }
}


################################################################################
# Kubernetes Service
################################################################################

resource "kubernetes_deployment" "java" {
  metadata {
    name = "microservice-deployment"
    labels = {
      app  = "java-microservice"
    }
  }
  
  

spec {
    replicas = var.replicas
    strategy {
  	type = "RollingUpdate"
  	rolling_update {
          max_surge       = "25%"
          max_unavailable = "25%"
      }
  } 

selector {
      match_labels = {
        app  = "java-microservice"
      }
    }
    
template {
      metadata {
        labels = {
          app  = "java-microservice"
        }
      }
      
spec {
        container {
          image = var.image
          name  = "java-microservice-container"
          port {
            container_port = var.pod_port
         }
        }
      }
    }
  }
}

resource "kubernetes_service" "java" {
  depends_on = [kubernetes_deployment.java]
  metadata {
    name = "java-microservice-service"
  }
  spec {
    selector = {
      app = "java-microservice"
    }
    port {
      port        = 80
      target_port = var.pod_port
    }
type = "LoadBalancer"
}
}
