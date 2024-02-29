#!/bin/bash

# Update the system
sudo yum update -y

# Install necessary packages
sudo yum install git python3 python3-pip -y
sudo pip3 install paramiko ansible

# Create a new user "ancon" with password "ancon"
sudo useradd -m -s /bin/bash ancon
echo "ancon:ancon" | sudo chpasswd

# Grant sudoer access to "ancon"
echo "ancon ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null

# Switch to "ancon" user
sudo su - ancon << EOF

# Create a .ssh directory
mkdir -p ~/.ssh

# Pull the repository
git clone -b master https://github.com/nahorov/ip-info-app.git /tmp/ip-info-app

# Pull the key-pair file
cp /tmp/ip-info-app/terraform/20240228.pem ~/.ssh/20240228.pem || { echo "Error: Copying key-pair file failed"; exit 1; }
chmod 400 ~/.ssh/20240228.pem || { echo "Error: Setting permissions on key-pair file failed"; exit 1; }

# Define inventory file
cat <<EOF > inventory.ini
[all]
java_jenkins_maven ansible_host=10.0.1.6
nexus ansible_host=10.0.2.5

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file="~/.ssh/20240228.pem"
ansible_ssh_common_args="-o StrictHostKeyChecking=no"
EOF

# Remove the terraform and ip-info-app folders
rm -rf /tmp/ip-info-app/terraform /tmp/ip-info-app/ip-info-app || { echo "Error: Removing folders failed"; exit 1; }

# Download Java JDK Corretto 17
sudo wget -O /tmp/java.tar.gz https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.tar.gz

# Download Sonatype Nexus
sudo wget -O /tmp/nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz

# Run the playbooks
ansible-playbook -i ~/inventory.ini /tmp/ip-info-app/ansible/java-jenkins-maven/java-jenkins-maven.yml
ansible-playbook -i ~/inventory.ini /tmp/ip-info-app/ansible/nexus/nexus.yml
ansible-playbook -i ~/inventory.ini /tmp/ip-info-app/ansible/kube-argo-jump/kube-argo-jump.yml
EOF

echo "Setup completed successfully."

