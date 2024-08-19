
provider "aws" {
   region = "eu-north-1"
}

module "vpc" {
   source = "terraform-aws-modules/vpc/aws"

   name = "demo-vpc"
   cidr = var.vpc_cidr_block

   azs             = [var.avail_zone]
   private_subnets = [var.private_subnet_cidr_block]
   public_subnets  = [var.subnet_cidr_block]

   private_subnet_tags = { 
      Name = "${var.env_prefix}-subnet-db" 
   }
   public_subnet_tags = { 
      Name = "${var.env_prefix}-subnet-1" 
   } 

   tags = {
      Name = "${var.env_prefix}-subnet-1"
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