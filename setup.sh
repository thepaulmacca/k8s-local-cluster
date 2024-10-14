#!/bin/sh
set -o errexit

# default config file
readonly CONFIG_FILE=${1:-single-node.yaml}

# before changing k8s node version, check the kind release pages for node version (https://github.com/kubernetes-sigs/kind/releases) and use the exact image including the digest
readonly NODE_K8S_VERSION=${NODE_K8S_VERSION:-v1.31.0@sha256:53df588e04085fd41ae12de0c3fe4c72f7013bba32a20e7325357a1ac94ba865}

kind create cluster --config="configs/$CONFIG_FILE" --image "kindest/node:$NODE_K8S_VERSION" --wait 60s

echo "Installing Calico CNI Plugin🔌..."

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/calico.yaml

echo "Waiting for Calico CNI Plugin to become ready⌛..."

kubectl wait --namespace kube-system \
  --for=condition=ready pod \
  --selector=k8s-app=calico-kube-controllers \
  --timeout=5m

echo "Installing NGINX Ingress Controller🚦..."

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Waiting for NGINX ingress controller to become ready⌛..."

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=5m

echo "Applying Helmfile ☸️..."

helmfile apply -f helmfile.yaml

echo "Creating Argo CD API Server Ingress🚦..."

kubectl apply -f argocd-server-ingress.yaml

echo "Setup complete! ✅"
