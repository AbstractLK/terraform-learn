output "ami_id" {
  value = module.my_server.ami.id
}
output "ec2_public_ip" {
  value = module.my_server.instance.public_ip
}