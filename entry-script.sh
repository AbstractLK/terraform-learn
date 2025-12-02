#!/bin/bash
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo docker run -d -p 8080:80 --name webserver nginx
echo "Web server $(hostname -f) is up and running" > /usr/share/nginx/html/index.html