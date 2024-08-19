resource "aws_security_group" "demo-app-sg" {

   name = "demo-app-sg"
   vpc_id = var.vpc_id
   
   ingress {
      from_port = 22
      to_port = 22
      protocol = "TCP"
      cidr_blocks = [var.my_ip]
   }

   ingress {
      from_port = 8080
      to_port = 8080
      protocol = "TCP"
      cidr_blocks = [var.web_access_ip]
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      prefix_list_ids = []
   }

   tags = {
      Name: "${var.env_prefix}-default-sg"
   }

}

data "aws_ami" "latest-amazon-linux-image" {
   most_recent = true
   owners = ["amazon"]
   filter {
      name = "name"
      values =[var.image_name]

   }
}

/*  resource "aws_key_pair" "ssh_key" {
   key_name = "server-key"
   public_key = file(var.public_key_location)
 } */

resource "aws_instance" "demo-app-server" {
   ami = data.aws_ami.latest-amazon-linux-image.id
   instance_type = var.instance_type

   subnet_id = var.subnet_id
   vpc_security_group_ids = [aws_security_group.demo-app-sg.id]
   availability_zone = var.avail_zone

   associate_public_ip_address = true
   key_name = "server-key-pair"
   #key_name = aws_key_pair.ssh_key.key_name

   user_data = file("modules/webserver/script.sh")
   
   user_data_replace_on_change = true

   tags = {
      Name: "${var.env_prefix}-app-server"
   }

}