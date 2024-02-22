#!/bin/bash

# Script to install Java, Jenkins, and other dependencies on c2

# Update the system
sudo yum update -y

# Install Java and Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
sudo dnf install java-17-amazon-corretto -y
sudo yum install jenkins -y

# Stop Jenkins temporarily
sudo systemctl stop jenkins

# Backup Jenkins configuration file
sudo cp /var/lib/jenkins/config.xml /var/lib/jenkins/config.xml.bkp

# Disable security temporarily (for initial setup)
sudo sed -i 's/<useSecurity>true<\/useSecurity>/<useSecurity>false<\/useSecurity>/' /var/lib/jenkins/config.xml

# Start Jenkins
sudo systemctl start jenkins

# Wait for Jenkins to start
sleep 30

# Install Jenkins plugins (Maven and Jib)
sudo wget -O /var/lib/jenkins/plugins/maven-plugin.hpi https://updates.jenkins.io/download/plugins/maven-plugin/latest/maven-plugin.hpi
sudo wget -O /var/lib/jenkins/plugins/jib.hpi https://updates.jenkins.io/download/plugins/jib/latest/jib.hpi

# Download Jenkins CLI (jenkins-cli.jar) for webhook configuration
sudo wget -O /var/lib/jenkins/jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar

# Restart Jenkins to apply changes
sudo systemctl restart jenkins

echo "Jenkins setup completed successfully."

