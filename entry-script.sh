#!/bin/bash
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
echo "<h1>Web server $(hostname -f) is up and running</h1>" > /tmp/index.html
sudo docker run -d -p 8080:80 --name webserver -v /tmp/index.html:/usr/share/nginx/html/index.html:ro nginx