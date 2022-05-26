output "name" {
value = var.name
}

output "image" {
value = var.image
}

output "lb_dns_name" {
  description 	= "The DNS name of the load balancer"
  value 	= kubernetes_service.java.status.0.load_balancer.0.ingress.0.hostname
}
