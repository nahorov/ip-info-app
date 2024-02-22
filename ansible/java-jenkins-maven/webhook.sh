#!/bin/bash

# Jenkins credentials (replace with your Jenkins username and password)
JENKINS_USERNAME="admin"
JENKINS_PASSWORD="admin"

# Jenkins URL and job name
JENKINS_URL="http://10.0.1.6:8080"
JOB_NAME="configure_webhook"

# GitHub repository URL
GITHUB_REPO="https://github.com/nahorov/ip-info-app"

# Generate Jenkins API token
JENKINS_API_TOKEN=$(curl -s -X POST -u "${JENKINS_USERNAME}:${JENKINS_PASSWORD}" "${JENKINS_URL}/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken" | jq -r '.data.tokenValue')

# Configure GitHub webhook
java -jar jenkins-cli.jar \
  -auth ${JENKINS_USERNAME}:${JENKINS_API_TOKEN} \
  -s ${JENKINS_URL} \
  create-webhook ${JOB_NAME} \
  --username ${JENKINS_USERNAME} \
  --password ${JENKINS_API_TOKEN} \
  --url ${GITHUB_REPO}/github-webhook/ \
  --event push

echo "Webhook configured successfully."

