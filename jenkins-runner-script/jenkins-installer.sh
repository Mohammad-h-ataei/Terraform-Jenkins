#!/bin/bash
# Cloud-init user data: installs Jenkins (LTS) and Terraform on Ubuntu 22.04.
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y fontconfig openjdk-17-jre-headless curl gnupg unzip software-properties-common

# Jenkins LTS repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  -o /usr/share/keyrings/jenkins-keyring.asc
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  > /etc/apt/sources.list.d/jenkins.list

# HashiCorp repository (Terraform)
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor \
  -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  > /etc/apt/sources.list.d/hashicorp.list

apt-get update -y
apt-get install -y jenkins terraform

systemctl enable --now jenkins
