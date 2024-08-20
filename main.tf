
provider "aws" {
   region = "eu-north-1"
}

resource "aws_security_group" "demo-lb-sg" {

   name = "demo-lb-sg"
   vpc_id = module.vpc.vpc_id
   
   ingress {
      from_port = 80
      to_port = 80
      protocol = "TCP"
      cidr_blocks = ["77.222.240.2/32"]
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      prefix_list_ids = []
   }

   tags = {
      Name: "${var.env_prefix}-default-lb-sg"
   }

}

// VPC
module "vpc" {
   source = "terraform-aws-modules/vpc/aws"

   name = "demo-vpc"
   cidr = var.vpc_cidr_block

   azs             = [var.avail_zone, var.avail_zone2]
   private_subnets = [var.private_subnet_cidr_block]
   public_subnets  = [var.subnet_cidr_block_1, var.subnet_cidr_block_2]

    private_subnet_tags = { 
      Name = "${var.env_prefix}-subnet-db" 
   }
   public_subnet_tags = { 
      Name = "${var.env_prefix}-subnet-app" 
   } 

   tags = {
      Name = "${var.env_prefix}-demo-vpc"
   }
}

// Target group
resource "aws_lb_target_group" "demo-tg" { 
 name     = "app-target-group"
 port     = 80
 protocol = "HTTP"
 vpc_id   = module.vpc.vpc_id

 tags = {
      Name = "${var.env_prefix}-demo-lb-tg"
   }
}

// Target group attachment
resource "aws_lb_target_group_attachment" "demo-tg-attachment" {
 target_group_arn = aws_lb_target_group.demo-tg.arn
 target_id        = module.demo-server.instance.id
 port             = 80
}

// ALB
resource "aws_lb" "demo_alb" {
 name               = "demo-alb"
 internal           = false
 load_balancer_type = "application"
 #security_groups    = [module.demo-server.app-security-group.id]
 security_groups    = [aws_security_group.demo-lb-sg.id]
 subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

 tags = {
      Name = "${var.env_prefix}-demo-alb"
 }
}

// Listener
resource "aws_lb_listener" "demo_alb_listener" {
 load_balancer_arn = aws_lb.demo_alb.arn
 port              = "80"
 protocol          = "HTTP"

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.demo-tg.arn
 }
}

module "demo-server" {
   source = "./modules/webserver"
   vpc_id = module.vpc.vpc_id
   my_ip = var.my_ip
   web_access_ip = var.web_access_ip
   env_prefix = var.env_prefix
   image_name = var.image_name
   instance_type = var.instance_type
   subnet_id = module.vpc.public_subnets[0]
   avail_zone = var.avail_zone

}