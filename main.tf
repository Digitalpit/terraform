
provider "aws" {
   region = "eu-north-1"
}

resource "aws_vpc" "demo-vpc" {
   cidr_block =  var.vpc_cidr_block
   tags = {
      Name: "${var.env_prefix}-vpc"
   }
}

module "demo-subnet" {
   source = "./modules/subnet"
   subnet_cidr_block = var.subnet_cidr_block
   avail_zone = var.avail_zone
   env_prefix = var.env_prefix
   vpc_id = aws_vpc.demo-vpc.id
   default_route_table_id = aws_vpc.demo-vpc.default_route_table_id
}

module "demo-server" {
   source = "./modules/webserver"
   vpc_id = aws_vpc.demo-vpc.id
   my_ip = var.my_ip
   web_access_ip = var.web_access_ip
   env_prefix = var.env_prefix
   image_name = var.image_name
   instance_type = var.instance_type
   subnet_id = module.demo-subnet.subnet.id
   avail_zone = var.avail_zone

}