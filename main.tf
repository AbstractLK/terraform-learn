provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block       = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

module "my-subnet" {
  source = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  az = var.az
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.my_vpc.id
  default_route_table_id = aws_vpc.my_vpc.default_route_table_id
}

module "my_server" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.my_vpc.id
  my_ip = var.my_ip
  env_prefix = var.env_prefix
  ami_name = var.ami_name
  public_key_path = var.public_key_path
  instance_type = var.instance_type
  subnet_id = module.my-subnet.subnet.id
  private_key_path = var.private_key_path
}