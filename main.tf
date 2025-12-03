terraform {
  required_version = ">= 1.0.0"
  backend "s3" {
    bucket = "abstraxlk-tf-state"
    key = "my-bucket/state.tfstate"
    region = "ap-southeast-1"
  }
}

provider "aws" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.az]
  public_subnets  = [var.subnet_cidr_block]
  public_subnet_tags = {
    Name = "${var.env_prefix}-subnet-1"
  }  

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

module "my_server" {
  source = "./modules/webserver"
  vpc_id = module.vpc.vpc_id
  my_ip = var.my_ip
  env_prefix = var.env_prefix
  ami_name = var.ami_name
  public_key_path = var.public_key_path
  instance_type = var.instance_type
  subnet_id = module.vpc.public_subnets[0]
  az = var.az
  private_key_path = var.private_key_path
}