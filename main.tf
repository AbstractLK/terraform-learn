provider "aws" {
  region = "ap-southeast-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable az {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}

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

resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.my_vpc.id
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ var.my_ip ]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    prefix_list_ids = []
  }
  tags = {
    Name = "${var.env_prefix}-sg-default"
  }
}

data "aws_ami" "amazon-linux-image" {
  most_recent = true
  owners = [ "137112412989" ]
  filter {
    name = "name"
    values = [ "al2023-ami-2023*-x86_64" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
}

output "ami_id" {
  value = data.aws_ami.amazon-linux-image.id
}

resource "aws_instance" "my-server" {
  ami = data.aws_ami.amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.my_subnet_1.id
  vpc_security_group_ids = [ aws_default_security_group.default_sg.id ]
  associate_public_ip_address = true
  key_name = "MyWebServer"
  tags = {
    Name = "${var.env_prefix}-server"
  }
}