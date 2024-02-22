#!/bin/bash

# Update the system
yum update -y

# Install necessary packages
yum install -y docker ansible

# Start Docker and enable it to start on boot
systemctl start docker
systemctl enable docker

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube
minikube start --driver=none

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Configure ArgoCD to use Minikube's IP
minikube_ip=$(minikube ip)
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer", "externalIPs":["'$minikube_ip'"]}}'

# Clone the ansible folder from the repository
wget -r -nH --cut-dirs=4 --no-parent --reject="index.html*" https://github.com/nahorov/ip-info-app/raw/master/ansible -P /tmp

echo "Setup complete."

