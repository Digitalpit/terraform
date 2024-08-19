
  output "ec2_app_public_IP" {
    value = module.demo-server.instance.public_ip
 }