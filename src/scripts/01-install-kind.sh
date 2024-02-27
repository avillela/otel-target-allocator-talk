#! /bin/bash

# ---------------------------
# -- Kubernetes installation
# ---------------------------

# Install KinD
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind --version

# Create KinD cluster
kind create cluster --name otel-target-allocator-talk