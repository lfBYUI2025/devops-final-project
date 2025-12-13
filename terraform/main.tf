provider "aws" {
  region = "us-west-2"  # Good free-tier region; change if needed
}

resource "aws_security_group" "app_sg" {
  name        = "bulletin-board-sg"
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
    cidr_blocks = ["0.0.0.0/0"]  # SSH for debugging if needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami           = "ami-0aff18ec83b712f05"  # Amazon Linux 2023 in us-west-2 (free-tier eligible)
  instance_type = "t2.micro"  # Free tier

  security_groups = [aws_security_group.app_sg.name]

 user_data = <<-EOF
  #!/bin/bash
  yum update -y
  yum install -y docker
  service docker start
  usermod -a -G docker ec2-user
  docker pull lfbyui2025/devops-final-project:latest
  docker run -d --restart always -p 5000:5000 --name bulletin-app lfbyui2025/devops-final-project:latest
  # Log for debugging
  docker logs -f bulletin-app > /var/log/app.log 2>&1 &
EOF

  tags = {
    Name = "BulletinBoardApp"
  }
}

output "public_ip" {
  value = aws_instance.app.public_ip
}
