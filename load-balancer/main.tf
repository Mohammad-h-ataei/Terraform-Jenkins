variable "name" { type = string }
variable "security_group" { type = string }
variable "subnet_ids" { type = list(string) }
variable "target_group_arn" { type = string }
variable "certificate_arn" { type = string }

resource "aws_lb" "this" {
  name                       = var.name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.security_group]
  subnets                    = var.subnet_ids
  drop_invalid_header_fields = true

  tags = {
    Name = var.name
  }
}

# HTTP -> HTTPS redirect
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }
}

output "dns_name" {
  value = aws_lb.this.dns_name
}

output "zone_id" {
  value = aws_lb.this.zone_id
}
