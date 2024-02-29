#!/bin/bash

# Function to configure Nexus with Jenkins
configure_nexus_with_jenkins() {
  jenkins_url="http://10.0.1.6:8080"
  nexus_url="http://10.0.2.5:8082"
  jenkins_username="admin"
  jenkins_password="admin"

  curl -X POST -u "$jenkins_username:$jenkins_password" -d "
    import jenkins.model.*
    import hudson.plugins.nexus.*
    import hudson.plugins.nexus.NexusPublisher.DescriptorImpl

    def instance = Jenkins.getInstanceOrNull()
    if (instance != null) {
      def nexusPublisher = new NexusPublisher('', '', '$nexus_url', '', '', '')
      DescriptorImpl descriptor = nexusPublisher.getDescriptor()
      descriptor.setNexusUrl('$nexus_url')
      descriptor.save()
      println 'Nexus URL updated successfully.'
    } else {
      println 'Jenkins instance not found.'
    }
  " "$jenkins_url/scriptText"
}

# Function to install Java
install_java() {
  # Extract Java tarball
  tar -xf /tmp/java.tar.gz -C /opt/
  # Set JAVA_HOME environment variable
  echo 'export JAVA_HOME=/opt/java' >> /etc/profile
  source /etc/profile
}

# Function to install Nexus
install_nexus() {
  # Extract Nexus tarball
  tar -xf /tmp/nexus.tar.gz -C /opt/
}

# Main function
main() {
  # Install Java
  install_java

  # Install Nexus
  install_nexus

  # Start Nexus service
  systemctl start nexus
  systemctl enable nexus

  # Configure Nexus with Jenkins
  configure_nexus_with_jenkins
}

# Execute main function
main

