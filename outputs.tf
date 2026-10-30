output "jenkins_url" {
  description = "HTTPS URL of the Jenkins server."
  value       = "https://${var.jenkins_domain}"
}

output "jenkins_public_ip" {
  description = "Public IP of the Jenkins instance (SSH from allowed CIDRs only)."
  value       = module.jenkins.public_ip
}

output "ssh_command" {
  description = "SSH command for the Jenkins instance; adjust the key path to your private key."
  value       = "ssh -i <path-to-your-private-key> ubuntu@${module.jenkins.public_ip}"
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.alb.dns_name
}
