variable "name" { type = string }
variable "vpc_id" { type = string }
variable "instance_id" { type = string }

resource "aws_lb_target_group" "jenkins" {
  name     = var.name
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/login"
    port                = "8080"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
  }
}

resource "aws_lb_target_group_attachment" "jenkins" {
  target_group_arn = aws_lb_target_group.jenkins.arn
  target_id        = var.instance_id
  port             = 8080
}

output "arn" {
  value = aws_lb_target_group.jenkins.arn
}
