
provider "aws" {
   region = "eu-north-1"
}

resource "aws_security_group" "demo-lb-sg" {

   name     = "demo-lb-sg"
   vpc_id   = module.vpc.vpc_id
   
   ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "TCP"
      cidr_blocks = [var.web_access_ip]
   }

ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "TCP"
      cidr_blocks = [var.web_access_ip]
   }

   egress {
      description = "listeners and healthcheck"
      from_port         = 80
      to_port           = 80
      protocol          = "TCP"
      cidr_blocks       = [var.subnet_cidr_block_1, var.subnet_cidr_block_2]
      prefix_list_ids   = []
   }

   tags = {
      Name: "${var.env_prefix}-default-lb-sg"
   }

}

# VPC
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

# Target group
resource "aws_lb_target_group" "demo-tg" { 
 name     = "app-target-group"
 port     = 80
 protocol = "HTTP"
 vpc_id   = module.vpc.vpc_id

 health_check {
    enabled             = true
    port                = 80
    interval            = 30
    protocol            = "HTTP"
    path                = "/index.html"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

 tags = {
      Name = "${var.env_prefix}-demo-lb-tg"
   }
}

# Target group attachment
resource "aws_lb_target_group_attachment" "demo-tg-attachment" {
 target_group_arn = aws_lb_target_group.demo-tg.arn
 target_id        = module.demo-server.instance.id
 port             = 80
}

 # ALB
resource "aws_lb" "demo_alb" {
 name               = "demo-alb"
 internal           = false
 load_balancer_type = "application"
 security_groups    = [aws_security_group.demo-lb-sg.id]
 subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

 tags = {
      Name = "${var.env_prefix}-demo-alb"
 }
}

# Listener HTTP
resource "aws_lb_listener" "demo_alb_listener" {
 load_balancer_arn = aws_lb.demo_alb.arn
 port              = "80"
 protocol          = "HTTP"

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.demo-tg.arn
 }
}
/*
# Request and validate an SSL certificate from AWS Certificate Manager (ACM)
resource "aws_acm_certificate" "demo-certificate" {
  domain_name       = "example.com"
  validation_method = "DNS"

  tags = {
    Name = "Demo SSL certificate"
  }
}

# Associate the SSL certificate with the ALB listener
resource "aws_lb_listener_certificate" "demo-lb-certificate" {
  listener_arn    = aws_lb_listener.demo_alb_listener.arn
  certificate_arn = aws_acm_certificate.demo-certificate.arn
}

# Listener HTTPS
resource "aws_lb_listener" "demo_alb_https_listener" {
 load_balancer_arn = aws_lb.demo_alb.arn
 port                = "443"
 protocol            = "HTTPS"
 certificate_arn     = aws_acm_certificate.demo-certificate.arn

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.demo-tg.arn
   
 }
}

resource "aws_route53_record" "node" {
  zone_id = "ZSxxxxxxx"
  name    = "www.example.com"
  type    = "A"
  alias {
    name                   = "${aws_lb.internal_alb.dns_name}"
    zone_id                = "${aws_lb.internal_alb.zone_id}"
    evaluate_target_health = true
  }
} */

# APP instance
module "demo-server" {
   source                     = "./modules/webserver"
   vpc_id                     = module.vpc.vpc_id
   my_ip                      = var.my_ip
   web_access_ip              = var.web_access_ip
   env_prefix                 = var.env_prefix
   image_name                 = var.image_name
   instance_type              = var.instance_type
   subnet_id                  = module.vpc.public_subnets[0]
   avail_zone                 = var.avail_zone
   private_subnet_cidr_block  = var.private_subnet_cidr_block

}

# DB instance
module "demo-db-server" {
   source               = "./modules/dbserver"
   vpc_id               = module.vpc.vpc_id
   env_prefix           = var.env_prefix
   image_name           = var.image_name
   instance_type        = var.instance_type
   subnet_id            = module.vpc.private_subnets[0]
   avail_zone           = var.avail_zone
   subnet_cidr_block_1  = var.subnet_cidr_block_1
   subnet_cidr_block_2  = var.subnet_cidr_block_2

}