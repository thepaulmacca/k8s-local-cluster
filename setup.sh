#!/bin/sh
set -o errexit

# default config file
readonly CONFIG_FILE=${1:-single-node.yaml}

# before changing k8s node version, check the kind release pages for node version (https://github.com/kubernetes-sigs/kind/releases) and use the exact image including the digest
readonly NODE_K8S_VERSION=${NODE_K8S_VERSION:-v1.31.2@sha256:18fbefc20a7113353c7b75b5c869d7145a6abd6269154825872dc59c1329912e}

kind create cluster --config="configs/$CONFIG_FILE" --image "kindest/node:$NODE_K8S_VERSION" --wait 60s

kubectl label node kind-control-plane node.kubernetes.io/exclude-from-external-load-balancers-

echo "Installing Calico CNI Plugin🔌..."

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/calico.yaml

echo "Waiting for Calico CNI Plugin to become ready⌛..."

kubectl wait --namespace kube-system \
  --for=condition=ready pod \
  --selector=k8s-app=calico-kube-controllers \
  --timeout=5m

echo "Installing NGINX Ingress Controller🚦..."

kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml

echo "Waiting for NGINX ingress controller to become ready⌛..."

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=5m

echo "Applying Helmfile ☸️..."

helmfile apply -f helmfile.yaml

echo "Setup complete! ✅"
