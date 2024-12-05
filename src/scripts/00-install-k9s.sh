#! /bin/bash

mkdir tmp

if [ $(uname -m) = x86_64 ]; then
    DISTRO="amd64"
elif [ $(uname -m) = aarch64 ]; then
    DISTRO="arm64"
fi

echo Distro is ${DISTRO}

# Download and install arch-specific .deb package for k9s
curl -Lo ./tmp/k9s_linux.deb https://github.com/derailed/k9s/releases/download/v0.32.7/k9s_linux_${DISTRO}.deb
chmod +x ./tmp/k9s_linux.deb
sudo dpkg -i ./tmp/k9s_linux.deb
rm -rf tmp