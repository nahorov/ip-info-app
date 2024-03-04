#!/bin/bash

# Variables
JENKINS_HOME="/var/lib/jenkins"
NEXUS_URL="http://10.0.2.5:8082"
NEXUS_USERNAME="new_user"
NEXUS_PASSWORD="new_password"
NEXUS_CREDENTIALS_FILE="nexus_credentials.xml"
JENKINS_JOB_CONFIG_FILE="jenkins_job_config.xml"
PIPELINE_SCRIPT="pipeline.groovy"

# Function to create Nexus credentials XML
create_nexus_credentials() {
    cat <<EOF > "$JENKINS_HOME/credentials/$NEXUS_CREDENTIALS_FILE"
<?xml version='1.0' encoding='UTF-8'?>
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>nexus-credentials</id>
  <description>Credentials for Nexus repository</description>
  <username>$NEXUS_USERNAME</username>
  <password>$NEXUS_PASSWORD</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
}

# Function to create Jenkins job configuration XML
create_jenkins_job_config() {
    cat <<EOF > "$JENKINS_HOME/jobs/ip-info-app/config.xml"
<?xml version='1.0' encoding='UTF-8'?>
<project>
  <actions/>
  <description>Sample Jenkins job for building and pushing to Nexus</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.plugins.git.GitSCM">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <url>https://github.com/nahorov/ip-info-app.git</url>
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <branches>
      <hudson.plugins.git.BranchSpec>
        <name>*/master</name>
      </hudson.plugins.git.BranchSpec>
    </branches>
    <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
    <gitTool>Default</gitTool>
    <submoduleCfg class="list"/>
    <extensions/>
  </scm>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>mvn clean package</command>
    </hudson.tasks.Shell>
    <hudson.tasks.Shell>
      <command>mvn compile jib:build</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers>
    <hudson.plugins.nexus.NexusPublisher>
      <nexusUrl>$NEXUS_URL</nexusUrl>
      <nexusVersion>3</nexusVersion>
      <protocol>http</protocol>
      <releaseRepositoryReleases>true</releaseRepositoryReleases>
      <snapshotRepositoryReleases>true</snapshotRepositoryReleases>
      <skipStaging>true</skipStaging>
      <nexusAuthId>nexus-credentials</nexusAuthId>
      <artifactId>ip-info-app</artifactId>
      <artifactType>docker.image</artifactType>
      <filesPattern>**/*.tar.gz</filesPattern>
      <skipPom>false</skipPom>
      <groupId>com.example</groupId>
      <version>1.0-SNAPSHOT</version>
      <generatePom>false</generatePom>
      <mavenArtifact>docker.image</mavenArtifact>
    </hudson.plugins.nexus.NexusPublisher>
  </publishers>
  <buildWrappers/>
</project>
EOF
}

# Create Nexus credentials XML
create_nexus_credentials

# Create Jenkins job configuration XML
create_jenkins_job_config

# Set ownership and permissions
sudo chown jenkins:jenkins "$JENKINS_HOME/credentials/$NEXUS_CREDENTIALS_FILE" "$JENKINS_HOME/jobs/ip-info-app/config.xml"
sudo chmod 644 "$JENKINS_HOME/credentials/$NEXUS_CREDENTIALS_FILE" "$JENKINS_HOME/jobs/ip-info-app/config.xml"

# Reload Jenkins to apply changes
sudo systemctl restart jenkins

echo "Nexus credentials and Jenkins job configuration files generated successfully."

