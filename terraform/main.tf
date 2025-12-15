provider "aws" {
  region = "us-west-2"  # Good free-tier region
}

resource "aws_security_group" "app_sg" {
  name_prefix = "bulletin-board-sg-"  # Auto-unique on re-apply
  description = "Allow inbound traffic on port 5000"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "app" {
  ami           = "ami-0aff18ec83b712f05"  # Amazon Linux 2023 us-west-2
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    service docker start
    usermod -a -G docker ec2-user

    until docker info >/dev/null 2>&1; do
      echo "Waiting for Docker..."
      sleep 10
    done

    docker pull lfbyui2025/devops-final-project:latest

    docker stop bulletin-app || true
    docker rm bulletin-app || true

    docker run -d --restart always -p 5000:5000 --name bulletin-app lfbyui2025/devops-final-project:latest
  EOF

  tags = {
    Name = "BulletinBoardApp"
  }
}

output "public_ip" {
  value = aws_instance.app.public_ip
}
