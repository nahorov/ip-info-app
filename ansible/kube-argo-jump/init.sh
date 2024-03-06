#!/bin/bash

# Update the system
sudo yum update -y

# Install necessary packages
sudo yum install policycoreutils* git python3 python3-pip -y
sudo pip3 install paramiko ansible
sudo semanage port -a -t http_port_t -p tcp 8080
sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
sudo firewall-cmd --reload
# Pull the repository to /tmp
git clone -b master https://github.com/nahorov/ip-info-app.git /tmp/ip-info-app

# Pull the key-pair file
cp /tmp/ip-info-app/terraform/20240228.pem ~/.ssh/20240228.pem || { echo "Error: Copying key-pair file failed"; exit 1; }
chmod 400 ~/.ssh/20240228.pem || { echo "Error: Setting permissions on key-pair file failed"; exit 1; }

# Define inventory file
cat <<EOF > ~/.ssh/inventory.ini
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

# Download policycoreutils.rpm
sudo wget -O /tmp/policycoreutils.rpm https://cdn.amazonlinux.com/2/core/2.0/x86_64/6b0225ccc542f3834c95733dcf321ab9f1e77e6ca6817469771a8af7c49efe6c/../../../../../blobstore/7bb091b2f632844cc58a6ee08370aaeb2da471ee376cfcff2b6de79ce0e2a2f6/policycoreutils-sandbox-2.5-17.1.amzn2.x86_64.rpm
sudo chmod 666 /tmp/policycoreutils.rpm

# Download Java JDK Corretto 17
sudo wget -O /tmp/java.tar.gz https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.tar.gz
sudo chmod 666 /tmp/java.tar.gz

# Download Sonatype Nexus
sudo wget -O /tmp/nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz
sudo chmod 666 /tmp/nexus.tar.gz

# Run the playbooks
ansible-playbook -i ~/.ssh/inventory.ini /tmp/ip-info-app/ansible/nexus/nexus.yml -vvv
ansible-playbook -i ~/.ssh/inventory.ini /tmp/ip-info-app/ansible/java-jenkins-maven/java-jenkins-maven.yml -vvv
ansible-playbook -i ~/.ssh/inventory.ini /tmp/ip-info-app/ansible/kube-argo-jump/install-docker-kube-argo-helm.yml -vvv
ansible-playbook -i ~/.ssh/inventory.ini /tmp/ip-info-app/ansible/kube-argo-jump/trigger-nexus.yml -vvv > /tmp/init-diagnosis.log

echo "Setup completed successfully."

