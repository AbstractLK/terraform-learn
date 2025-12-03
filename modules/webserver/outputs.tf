output "instance" {
  value = aws_instance.my_server
}
output "ami" {
  value = data.aws_ami.amazon-linux-image
}