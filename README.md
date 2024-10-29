# Kubernetes Local Cluster

## Overview

A local Kubernetes cluster using [kind](./setup.sh). This will be regularly updated to use the default node image for each [release](https://github.com/kubernetes-sigs/kind/releases).

Using a local cluster is great for learning, experimentation and practice. It's also useful to have when you're studying for any of the Kubernetes certifications.

> [!NOTE]
> For the [CKS exam](https://training.linuxfoundation.org/certification/certified-kubernetes-security-specialist/), you'll have to create a bare-metal cluster due to limitations with kind. I've found the [cks-course-environment](https://github.com/killer-sh/cks-course-environment/tree/master) repo to be sufficient, although you'll need to tweak it as per the [upcoming changes](https://training.linuxfoundation.org/cks-program-changes/) to the curriculum.

## Getting Started

### Single Node Cluster

Run `./setup.sh` to install a single-node cluster (default).

### Multi-Node Cluster

Run `./setup.sh multi-node.yaml` to install a multi-node cluster with one control plane and 2 worker nodes.

## Installed Software

The `setup.sh` script installs:

- Calico for testing Network Policies
- Ingress NGINX for testing Ingress

All other software is currently installed using a [helmfile](helmfile.yaml). I'm planning on using Argo CD instead in the near future.

## Ingress

I'm using [nip.io](https://nip.io/) for the below resources.

### Argo CD API Server

An ingress resource is created for accessing the Argo CD API Server. Go to [http://argocd.127.0.0.1.nip.io](http://argocd.127.0.0.1.nip.io) and then follow the rest of the [login instructions](https://argo-cd.readthedocs.io/en/stable/getting_started/#4-login-using-the-cli).

### Prometheus

Ingress has been enabled via the [values-kube-prometheus-stack.yaml](values-kube-prometheus-stack.yaml) file. Go to [http://prometheus.127.0.0.1.nip.io](http://prometheus.127.0.0.1.nip.io) to access the server.

### Grafana

Ingress has been enabled via the [values-kube-prometheus-stack.yaml](values-kube-prometheus-stack.yaml) file. Go to [http://grafana.127.0.0.1.nip.io](http://grafana.127.0.0.1.nip.io) and login with:

- Username: admin
- Password: prom-operator
