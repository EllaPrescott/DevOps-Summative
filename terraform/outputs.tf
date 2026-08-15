# Outputs for the EC2 instance ID and public IP address 

output "instance_id" {
  value = aws_instance.flask.id
}

output "public_ip" {
  value = aws_instance.flask.public_ip
}
