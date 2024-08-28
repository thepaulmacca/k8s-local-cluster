#!/bin/sh
set -o errexit

minikube start \
  --addons=ingress \
  --addons=ingress-dns \
  --addons=metrics-server \
  --cni=calico \
  --cpus=no-limit \
  --disable-optimizations=true \
  --extra-config=controller-manager.bind-address=0.0.0.0 \
  --extra-config=etcd.listen-metrics-urls=http://0.0.0.0:2381 \
  --extra-config=kubelet.authentication-token-webhook=true \
  --extra-config=kubelet.authorization-mode=Webhook \
  --extra-config=scheduler.bind-address=0.0.0.0 \
  --feature-gates=InPlacePodVerticalScaling=true \
  --memory=no-limit \

echo "Applying helmfile ☸️..."

helmfile apply --file helmfile.yaml

echo "Setup complete! ✅"
