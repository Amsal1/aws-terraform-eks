/*terraform {

  backend "s3" {
    bucket         = "amsalkhan"
    key            = "vpc-lb-eks/state.tfstate"
    region         = "ap-south-1"
    encrypt        = "true"
    dynamodb_table = "terraform-app-state"
  }
}*/


module "vpc-lb-eks" {
  source = "./vpc-lb-eks"
  environment = var.environment
  region = var.region
  
  name = "java-cluster"
  cluster_version = "1.21"
  
  #image = "511061490505.dkr.ecr.ap-south-1.amazonaws.com/java-demo"
  image = "nginxdemos/hello:latest"
  pod_port = 80
  
  instance_type = ["t3.small"]
  replicas = 2
  disk_size = 12
  desired_size = 2
  max_size = 3
  min_size = 1
  
  #public_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
}
