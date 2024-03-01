#!/bin/bash

# Update the system
sudo yum update -y

# Install necessary packages
sudo yum install git python3 python3-pip -y
sudo pip3 install paramiko ansible

# Add Ansible to PATH for the ancon user
sudo -u ancon bash -c 'echo "export PATH=$PATH:/usr/local/bin" >> ~/.bashrc'

# Pull the repository
git clone -b master https://github.com/nahorov/ip-info-app.git /tmp/ip-info-app

# Create a new user "ancon" with password "ancon"
sudo useradd -m -s /bin/bash ancon
echo "ancon:ancon" | sudo chpasswd

# Grant sudoer access to "ancon"
echo "ancon ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null

