resource "aws_instance" "web_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.small"
  subnet_id                   = "subnet-390c6f43"
  security_groups             = [aws_security_group.web_sg.name]
  key_name                    = "interview"
  associate_public_ip_address = true
  user_data                   = file("scripts/bootstrap.sh")

  tags = {
    Name = "Web"
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web_security_group"
  description = "..."
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
