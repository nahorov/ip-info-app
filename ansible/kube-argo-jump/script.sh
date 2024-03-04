#!/bin/bash

# Install Docker
echo "Installing Docker..."
sudo yum install -y docker

# Start Docker service
echo "Starting Docker service..."
sudo systemctl start docker

# Install Kubernetes
echo "Installing Kubernetes..."
sudo yum install -y kubelet kubeadm kubectl

# Start and enable kubelet service
echo "Starting and enabling kubelet service..."
sudo systemctl enable kubelet
sudo systemctl start kubelet

# Install Helm
echo "Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod +x get_helm.sh
./get_helm.sh

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD server to be ready
echo "Waiting for ArgoCD server to be ready..."
while [[ $(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do 
  echo "ArgoCD server is not ready yet, waiting..."
  sleep 10
done

# Create new user in ArgoCD
echo "Creating new user in ArgoCD..."
kubectl -n argocd create secret generic argocd-initial-admin-secret \
  --from-literal=argocd-initial-admin-password=$(openssl rand -base64 12)

# Get ArgoCD server address
echo "ArgoCD server address:"
kubectl -n argocd get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

echo "Setup complete."

