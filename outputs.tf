output "environemnt" {
value = var.environment
}

output "region" {
value = var.region
}

output "vpc-alb-sam" {
  value = module.vpc-lb-eks
}
