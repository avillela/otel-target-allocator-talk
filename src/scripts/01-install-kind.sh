#! /bin/bash

# ---------------------------
# -- Kubernetes installation
# ---------------------------

# Get distro information
if [ $(uname -m) = x86_64 ]; then
    DISTRO="amd64"
elif [ $(uname -m) = aarch64 ]; then
    DISTRO="arm64"
fi

echo "Distro is ${DISTRO}"


# Install KinD
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-${DISTRO}
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind --version

# Create KinD cluster. See the following GitHub issue for more on why I had to resort to manually creating the docker network: https://github.com/kubernetes-sigs/kind/issues/3748
docker network create -d=bridge -o com.docker.network.bridge.enable_ip_masquerade=true -o com.docker.network.driver.mtu=1500 --subnet fc00:f853:ccd:e793::/64 kind
kind create cluster --name otel-target-allocator-talk

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${DISTRO}/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm ./get_helm.sh