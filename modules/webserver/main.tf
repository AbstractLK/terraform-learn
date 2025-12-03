resource "aws_default_security_group" "default_sg" {
  vpc_id = var.vpc_id
  
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
    values = [ var.ami_name ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name = "myKey"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "my_server" {
  ami = data.aws_ami.amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [ aws_default_security_group.default_sg.id ]
  # availability_zone = var.az
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh_key.key_name
  tags = {
    Name = "${var.env_prefix}-server"
  }

  /* user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y docker
                systemctl start docker
                systemctl enable docker
                sudo usermod -aG docker ec2-user
                docker run -d -p 8080:80 --name webserver nginx
              EOF */

  user_data = file("entry-script.sh")

  # connection {
  #   type = "ssh"
  #   host = self.public_ip
  #   user = "ec2-user"
  #   private_key = file(var.private_key_path)
  # }

  # provisioner "file" {
  #   source = "entry-script.sh"
  #   destination = "/home/ec2-user/script.sh"
  # }

  # provisioner "remote-exec" {
  #     inline = [ 
  #       # for windows -------------
  #       "dos2unix /home/ec2-user/script.sh 2>/dev/null || sed -i 's/\\r$//' /home/ec2-user/script.sh",
  #       # -------------------------
  #       "chmod +x /home/ec2-user/script.sh",
  #       "/home/ec2-user/script.sh"
  #     ]
  # }

  provisioner "local-exec" {
    command = "echo EC2 Instance Public IP: ${self.public_ip} > ec2_ip.txt"
  }

  /* lifecycle {
    ignore_changes = [ami]
  } */

}