#!/bin/bash

# SSH details
SSH_USER="ec2-user"
SSH_HOST="10.0.2.5"
SSH_KEY="~/.ssh/20240228.pem"

# Copy Java and Nexus tarballs to Nexus host
for item in java.tar.gz nexus.tar.gz; do
    scp -i "$SSH_KEY" "/tmp/$item" "$SSH_USER@$SSH_HOST:/tmp/$item"
done

# Copy install-java-and-nexus.sh script to Nexus host
scp -i "$SSH_KEY" "/tmp/ip-info-app/ansible/nexus/install-java-and-nexus.sh" "$SSH_USER@$SSH_HOST:/tmp/install-java-and-nexus.sh"

# Execute install-java-and-nexus.sh script on Nexus host
ssh -i "$SSH_KEY" "$SSH_USER@$SSH_HOST" "/bin/bash /tmp/install-java-and-nexus.sh"

# Display install-java-and-nexus.sh execution result (if needed)
# ssh -i "$SSH_KEY" "$SSH_USER@$SSH_HOST" "cat /tmp/install-java-and-nexus.log"

