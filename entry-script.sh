#!/bin/bash
sudo yum update -y
sudo yum install -y docker
systemctl start docker
systemctl enable docker
sudo usermod -aG docker ec2-user
docker run -d -p 8080:80 --name webserver nginx
# echo "Web server is up and running" > /usr/share/nginx/html/index.html