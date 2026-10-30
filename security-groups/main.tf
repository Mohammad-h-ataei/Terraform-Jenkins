variable "name" { type = string }
variable "vpc_id" { type = string }
variable "allowed_ssh_cidrs" { type = list(string) }

# ALB: the only component reachable from the internet over HTTP/HTTPS.
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Public HTTP/HTTPS access to the Jenkins load balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP (redirected to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-alb-sg"
  }
}

# Jenkins instance: port 8080 only from the ALB, SSH only from allowed CIDRs.
resource "aws_security_group" "jenkins" {
  name        = "${var.name}-jenkins-sg"
  description = "Jenkins instance access"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Jenkins UI from the load balancer only"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH from allowed admin IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  egress {
    description = "Allow all outbound (package installs, plugin downloads)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-jenkins-sg"
  }
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "jenkins_sg_id" {
  value = aws_security_group.jenkins.id
}
