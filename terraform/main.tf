
# Security group for Flask app and SSH access


resource "aws_security_group" "flask" {
  name        = "flask-sg"
  description = "Allow Flask and SSH"

  # AWS Academy default VPC is used automatically
  # (no vpc_id needed)

  ingress {
    description = "Flask App"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# AMI for Amazon Linux 2023 

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}


# EC2 instance for Flask app

resource "aws_instance" "flask" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.flask.id]
  associate_public_ip_address = true
  key_name                    = "vockey"

  user_data = <<-EOF
#!/bin/bash
dnf update -y
dnf install python3 python3-pip git -y

mkdir -p /opt/application
chmod 777 /opt/application

echo "Server Ready" > /tmp/server-status.txt
EOF

  tags = {
    Name = "FlaskApp"
  }
}


