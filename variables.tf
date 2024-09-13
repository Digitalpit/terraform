variable vpc_cidr_block {
    default = "10.0.0.0/16"
}
variable subnet_cidr_block_1 {
    default = "10.0.10.0/24"
}
variable subnet_cidr_block_2 {
    default = "10.0.20.0/24"
}
variable private_subnet_cidr_block {
    default = "10.0.30.0/24"
}
variable avail_zone {
    default = "eu-north-1a"
}
variable avail_zone2 {
    default = "eu-north-b"
}
variable env_prefix {
    default = "dev"
}
variable my_ip {
    default = "77.222.240.2/32"    
}
variable web_access_ip {
   default = "77.222.240.2/32" 
}
variable instance_type {
    default = "t3.micro"
}
variable public_key_location {
    default = "~/.ssh/id_ed25519.pub"
}
variable image_name {
    default = "amzn2-ami-kernel-*-x86_64-gp2"
}