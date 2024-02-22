#!/bin/bash

# Variables
JENKINS_HOME="/var/lib/jenkins"
PIPELINE_SCRIPT="pipeline.groovy"
NEXUS_URL="http://10.0.2.5:8082"

# Create Jenkins pipeline script
cat <<EOF > "$JENKINS_HOME/pipeline/$PIPELINE_SCRIPT"
pipeline {
    agent any
    
    stages {
        stage('Clone repository') {
            steps {
                git 'https://github.com/nahorov/ip-info-app.git'
            }
        }
        
        stage('Build and containerize') {
            steps {
                script {
                    dir('ip-info-app') {
                        sh 'mvn clean package'
                        sh 'mvn compile jib:build'
                    }
                }
            }
        }
    }
}
EOF

# Set ownership and permissions
sudo chown jenkins:jenkins "$JENKINS_HOME/pipeline/$PIPELINE_SCRIPT"
sudo chmod 644 "$JENKINS_HOME/pipeline/$PIPELINE_SCRIPT"

# Reload Jenkins to apply changes
sudo systemctl restart jenkins

# Wait for Jenkins to restart
sleep 30

# Configure Nexus URL in Jenkins Global Configuration
java -jar $JENKINS_HOME/jenkins-cli.jar -s http://localhost:8080 groovy = < <(cat <<EOF
import jenkins.model.*
import hudson.plugins.nexus.*
import hudson.plugins.nexus.NexusPublisher.DescriptorImpl

def instance = Jenkins.getInstanceOrNull()
if (instance != null) {
    def nexusPublisher = new NexusPublisher("", "", "$NEXUS_URL", "", "", "")
    DescriptorImpl descriptor = nexusPublisher.getDescriptor()
    descriptor.setNexusUrl("$NEXUS_URL")
    descriptor.save()
    println "Nexus URL updated successfully."
} else {
    println "Jenkins instance not found."
}
EOF
)

echo "Jenkins pipeline script generated and integrated successfully."

