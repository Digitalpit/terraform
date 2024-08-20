
# Public IP APP EC2 instance
output "ec2_app_public_IP" {
  value       = module.demo-server.instance.public_ip
 }

# DNS of LoadBalancer
output "lb_dns_name" {
  description = "DNS of Load balancer"
  value       = aws_lb.demo_alb.dns_name
}