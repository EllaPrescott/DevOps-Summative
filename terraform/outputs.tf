# Outputs for the EC2 instance ID and public IP address 

output "ec2_instance_id" {
  value = aws_instance.flask.id
}

output "ec2_public_ip" {
  value = aws_instance.flask.public_ip
}
