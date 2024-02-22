#!/bin/bash

# Update the system
sudo yum update -y

# Install necessary packages
sudo yum install python3 python3-pip -y
sudo pip3 install paramiko ansible

# Create a new user "ancon" with password "ancon"
sudo useradd -m -s /bin/bash ancon
echo "ancon:ancon" | sudo chpasswd

# Grant sudoer access to "ancon"
echo "ancon ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null

# Switch to "ancon" user
sudo su - ancon << EOF

# Generate SSH key pair
ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa

# Define IP addresses
java_jenkins_maven_ip="10.0.1.6"
nexus_ip="10.0.2.5"

# Copy SSH public key to java_jenkins_maven_ip and nexus_ip
ssh-copy-id -i ~/.ssh/id_rsa.pub ancon@${java_jenkins_maven_ip}
ssh-copy-id -i ~/.ssh/id_rsa.pub ancon@${nexus_ip}

# Download the ansible folder from the provided URL
wget -r -nH --cut-dirs=2 --no-parent --reject="index.html*" https://github.com/nahorov/ip-info-app/tree/master/ansible -P /tmp/ansible

# Run the playbook
ansible-playbook /tmp/ansible/playbook.yml

EOF

echo "Setup completed successfully."

