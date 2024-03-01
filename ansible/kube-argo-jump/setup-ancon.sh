#!/bin/bash

# Create a .ssh directory
sudo -u ancon mkdir -p /home/ancon/.ssh

# Pull the key-pair file
sudo -u ancon cp /tmp/ip-info-app/terraform/20240228.pem /home/ancon/.ssh/20240228.pem || { echo "Error: Copying key-pair file failed"; exit 1; }
sudo -u ancon chmod 400 /home/ancon/.ssh/20240228.pem || { echo "Error: Setting permissions on key-pair file failed"; exit 1; }

# Define inventory file
sudo -u ancon tee /home/ancon/.ssh/inventory.ini >/dev/null <<EOF2
[all]
java_jenkins_maven ansible_host=10.0.1.6
nexus ansible_host=10.0.2.5

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file="/home/ancon/.ssh/20240228.pem"
ansible_ssh_common_args="-o StrictHostKeyChecking=no"
EOF2

# Run the rest of the commands
# Remove the terraform and ip-info-app folders
sudo -u ancon rm -rf /tmp/ip-info-app/terraform /tmp/ip-info-app/ip-info-app || { echo "Error: Removing folders failed"; exit 1; }

# Download Java JDK Corretto 17
sudo -u ancon wget -O /tmp/java.tar.gz https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.tar.gz

# Download Sonatype Nexus
sudo -u ancon wget -O /tmp/nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz

# Run the playbooks
sudo -u ancon ansible-playbook -i /home/ancon/.ssh/inventory.ini /tmp/ip-info-app/ansible/java-jenkins-maven/java-jenkins-maven.yml -vvv
sudo -u ancon ansible-playbook -i /home/ancon/.ssh/inventory.ini /tmp/ip-info-app/ansible/nexus/nexus.yml -vvv
sudo -u ancon ansible-playbook -i /home/ancon/.ssh/inventory.ini /tmp/ip-info-app/ansible/kube-argo-jump/kube-argo-jump.yml -vvv

echo "Setup completed successfully."

