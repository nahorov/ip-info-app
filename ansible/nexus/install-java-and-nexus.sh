#!/bin/bash

# Configure SELinux and Firewall
sudo semanage port -a -t http_port_t -p tcp 8082
sudo firewall-cmd --permanent --zone=public --add-port=8082/tcp
sudo firewall-cmd --reload

# Function to install Java
install_java() {
  echo "Installing Java..."
  tar -xf /tmp/java.tar.gz -C /opt/
  echo 'export JAVA_HOME=/opt/java' >> /etc/profile
  source /etc/profile
}

# Function to install Nexus
install_nexus() {
  echo "Installing Nexus..."
  tar -xf /tmp/nexus.tar.gz -C /opt/

  # Start Nexus (assuming Nexus is started via script or systemctl)
  /opt/nexus/bin/nexus start

  # Wait for Nexus to start (adjust sleep time as needed)
  sleep 60

  # Create a new user in Nexus
  echo "Creating Nexus user..."
  curl -X POST -u admin:admin123 --header "Content-Type: application/json" --data '{
    "userId": "new_user",
    "password": "new_password",
    "firstName": "First",
    "lastName": "Last",
    "email": "rollinstone1996@gmail.com",
    "status": "active"
  }' http://localhost:8082/service/rest/v1/users

  echo "Nexus user created successfully."
}

# Main function
main() {
  install_java
  install_nexus

  echo "Installation and configuration completed."
}

# Execute main function
main

