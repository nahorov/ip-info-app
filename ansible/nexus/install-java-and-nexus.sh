#!/bin/bash

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
}

# Function to configure Nexus with Jenkins
configure_nexus_with_jenkins() {
  echo "Configuring Nexus with Jenkins..."
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

# Main function
main() {
  install_java
  install_nexus

  systemctl start nexus
  systemctl enable nexus

  configure_nexus_with_jenkins

  echo "Installation and configuration completed."
}

# Execute main function
main

