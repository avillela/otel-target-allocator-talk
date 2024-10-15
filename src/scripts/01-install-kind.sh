#! /bin/bash

# ---------------------------
# -- Kubernetes installation
# ---------------------------

# Install KinD
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-arm64

chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind --version

# Create KinD cluster. See the following GitHub issue for more on why I had to resort to manually creating the docker network: https://github.com/kubernetes-sigs/kind/issues/3748
docker network create -d=bridge -o com.docker.network.bridge.enable_ip_masquerade=true -o com.docker.network.driver.mtu=1500 --subnet fc00:f853:ccd:e793::/64 kind
kind create cluster --name otel-target-allocator-talk

# Install kubectl
[ $(uname -m) = x86_64 ] && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
[ $(uname -m) = aarch64 ] && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"

chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
