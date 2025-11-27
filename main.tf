provider "aws" {}

variable "data" {
  description = "all cidr blocks and names"
    # default = "10.0.0.1/16"
    type = list(object({
      cidr_block = string
      name = string
    }))
}

variable az {
  default = "ap-southeast-1a"
}

resource "aws_vpc" "test_vpc" {
  cidr_block       = var.data[0].cidr_block
  instance_tenancy = "default"

  tags = {
    Name = var.data[0].name
  }
}

resource "aws_subnet" "test_subnet_1" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = var.data[1].cidr_block
  availability_zone = var.az
  tags = {
    Name = var.data[1].name
  }
}

output "test_vpc_id" {
  value = aws_vpc.test_vpc.id
}

output "aws_subnet_id" {
  value = aws_subnet.test_subnet_1.id
}