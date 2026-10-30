variable "name" { type = string }
variable "ami_id" { type = string }
variable "instance_type" { type = string }
variable "ssh_public_key" { type = string }
variable "subnet_id" { type = string }
variable "security_group_ids" { type = list(string) }
variable "user_data" { type = string }

resource "aws_key_pair" "jenkins" {
  key_name   = "${var.name}-key"
  public_key = var.ssh_public_key
}

resource "aws_instance" "jenkins" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.jenkins.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true
  user_data                   = var.user_data

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # enforce IMDSv2
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.name}-jenkins"
  }
}

output "instance_id" {
  value = aws_instance.jenkins.id
}

output "public_ip" {
  value = aws_instance.jenkins.public_ip
}
