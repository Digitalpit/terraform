output "instance" {
    value = aws_instance.demo-app-server
}

output "app-security-group" {
    value = aws_security_group.demo-app-sg
}