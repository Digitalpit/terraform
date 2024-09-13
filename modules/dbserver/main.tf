resource "aws_security_group" "demo-db-sg" {

   name     = "demo-db-sg"
   vpc_id   = var.vpc_id

   ingress {
      from_port   = 3306
      to_port     = 3306
      protocol    = "TCP"
      cidr_blocks = [var.subnet_cidr_block_1,var.subnet_cidr_block_2]
   }

   egress {
      from_port         = 80
      to_port           = 80
      protocol          = "TCP"
      cidr_blocks       = ["0.0.0.0/0"]
      prefix_list_ids   = []
   }

   egress {
      from_port         = 443
      to_port           = 443
      protocol          = "TCP"
      cidr_blocks       = ["0.0.0.0/0"]
      prefix_list_ids   = []
   }

   tags = {
      Name: "${var.env_prefix}-db-sg"
   }

}

data "aws_ami" "latest-amazon-linux-image" {
   most_recent = true
   owners      = ["amazon"]
   filter {
      name     = "name"
      values   =[var.image_name]

   }
}

resource "aws_instance" "demo-db-server" {
   ami                     = data.aws_ami.latest-amazon-linux-image.id
   instance_type           = var.instance_type

   subnet_id               = var.subnet_id
   vpc_security_group_ids  = [aws_security_group.demo-db-sg.id]
   availability_zone       = var.avail_zone

   associate_public_ip_address = false
   key_name                    = "server-key-pair"

   user_data                   = file("modules/webserver/script.sh")
   
   user_data_replace_on_change = true

   tags = {
      Name: "${var.env_prefix}-db-server"
   }

}