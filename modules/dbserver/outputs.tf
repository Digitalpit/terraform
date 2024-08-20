output "instance" {
    value = aws_instance.demo-db-server
}

output "app-security-group" {
    value = aws_security_group.demo-db-sg
}