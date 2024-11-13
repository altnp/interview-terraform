provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "interview_bastion_allow_ssh" {
  name        = "interview_bastion"
  description = "Allow SSH to Interview Bastion Instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["75.188.39.145/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "interview_bastion_role" {
  name = "interview_bastion_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "interview_bastion_policy" {
  name = "interview_bastion_policy"
  role = aws_iam_role.interview_bastion_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "ec2:*"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "interview_bastion_profile" {
  name = "interview_bastion_profile"
  role = aws_iam_role.interview_bastion_role.name
}

resource "aws_instance" "ubuntu_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.small"
  key_name                    = "interview"
  subnet_id                   = data.aws_subnets.default.ids[0]
  security_groups             = [aws_security_group.interview_bastion_allow_ssh.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.interview_bastion_profile.name
  user_data                   = <<-EOF
              #!/bin/bash
              echo "ubuntu:tcetrainterview" | sudo chpasswd
              echo -e "\nMatch User ubuntu\nPasswordAuthentication yes\nMatch all" | sudo tee -a /etc/ssh/sshd_config > /dev/null
              sudo systemctl restart sshd.service
              EOF

  tags = {
    Name = "Interview Bastion"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}


data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_vpc" "default" {
  default = true
}
