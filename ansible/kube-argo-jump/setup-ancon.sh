#!/bin/bash

# Create a .ssh directory
mkdir -p ~/.ssh

# Pull the key-pair file
cp /tmp/ip-info-app/terraform/20240228.pem ~/.ssh/20240228.pem || { echo "Error: Copying key-pair file failed"; exit 1; }
chmod 400 ~/.ssh/20240228.pem || { echo "Error: Setting permissions on key-pair file failed"; exit 1; }

# Define inventory file
tee ~/.ssh/inventory.ini >/dev/null <<EOF2
[all]
java_jenkins_maven ansible_host=10.0.1.6
nexus ansible_host=10.0.2.5

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file="~/.ssh/20240228.pem"
ansible_ssh_common_args="-o StrictHostKeyChecking=no"
EOF2

# Run the rest of the commands
# Remove the terraform and ip-info-app folders
rm -rf /tmp/ip-info-app/terraform /tmp/ip-info-app/ip-info-app || { echo "Error: Removing folders failed"; exit 1; }

# Download Java JDK Corretto 17
wget -O /tmp/java.tar.gz https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.tar.gz

# Download Sonatype Nexus
wget -O /tmp/nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz

# Run the playbooks
ansible-playbook -i ~/.ssh/inventory.ini /tmp/ip-info-app/ansible/java-jenkins-maven/java-jenkins-maven.yml -vvv
ansible-playbook -i ~/.ssh/inventory.ini /tmp/ip-info-app/ansible/nexus/nexus.yml -vvv
ansible-playbook -i ~/.ssh/inventory.ini /tmp/ip-info-app/ansible/kube-argo-jump/kube-argo-jump.yml -vvv

echo "Setup completed successfully."

