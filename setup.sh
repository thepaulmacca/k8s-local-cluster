#!/bin/sh
set -o errexit

# before changing k8s node version, check the kind release pages for node version (https://github.com/kubernetes-sigs/kind/releases) and use the exact image including the digest
readonly NODE_K8S_VERSION=${NODE_K8S_VERSION:-v1.30.0@sha256:047357ac0cfea04663786a612ba1eaba9702bef25227a794b52890dd8bcd692e}
readonly WAIT_FOR_CONTROLPLANE=60s

kind create cluster --config=configs/multi-node.yaml --image "kindest/node:$NODE_K8S_VERSION" --wait $WAIT_FOR_CONTROLPLANE

echo "Installing NGINX Ingress Controller 🚦..."

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Waiting for NGINX ingress controller to become ready ⌛..."

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "Applying Helmfile ☸️..."

helmfile apply --file helmfile.yaml

echo "Creating Argo CD API Server Ingress 🚦..."

kubectl apply -f argocd-ingress.yaml

echo "Setup complete! ✅"
