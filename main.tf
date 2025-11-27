provider "aws" {
  region = "ap-southeast-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable az {}
variable "env_prefix" {}

resource "aws_vpc" "my_vpc" {
  cidr_block       = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "my_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.az
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "my_internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main_rtb" {
  default_route_table_id = aws_vpc.my_vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_internet_gateway.id
  }
  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}