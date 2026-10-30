data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "networking" {
  source = "./networking"

  name                 = var.project_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security_groups" {
  source = "./security-groups"

  name              = var.project_name
  vpc_id            = module.networking.vpc_id
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
}

module "jenkins" {
  source = "./jenkins"

  name               = var.project_name
  ami_id             = data.aws_ami.ubuntu.id
  instance_type      = var.instance_type
  ssh_public_key     = var.ssh_public_key
  subnet_id          = module.networking.public_subnet_ids[0]
  security_group_ids = [module.security_groups.jenkins_sg_id]
  user_data          = file("${path.module}/jenkins-runner-script/jenkins-installer.sh")
}

module "lb_target_group" {
  source = "./load-balancer-target-group"

  name        = "${var.project_name}-tg"
  vpc_id      = module.networking.vpc_id
  instance_id = module.jenkins.instance_id
}

module "hosted_zone" {
  source = "./hosted-zone"

  hosted_zone_name = var.hosted_zone_name
  record_name      = var.jenkins_domain
  alb_dns_name     = module.alb.dns_name
  alb_zone_id      = module.alb.zone_id
}

module "certificate_manager" {
  source = "./certificate-manager"

  domain_name    = var.jenkins_domain
  hosted_zone_id = module.hosted_zone.hosted_zone_id
}

module "alb" {
  source = "./load-balancer"

  name             = "${var.project_name}-alb"
  security_group   = module.security_groups.alb_sg_id
  subnet_ids       = module.networking.public_subnet_ids
  target_group_arn = module.lb_target_group.arn
  certificate_arn  = module.certificate_manager.certificate_arn
}
