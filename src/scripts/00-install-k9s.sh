#! /bin/bash

# Uncomment ll alias in .bashrc (nice-to-have)
sed -i -e "s/#alias ll='ls -l'/alias ll='ls -al'/g" ~/.bashrc
. $HOME/.bashrc

# ---------------------------
# -- K9s installation
# ---------------------------

mkdir tmp

# Get distro information
if [ $(uname -m) = x86_64 ]; then
    DISTRO="amd64"
elif [ $(uname -m) = aarch64 ]; then
    DISTRO="arm64"
fi

echo "Distro is ${DISTRO}"

# Download and install arch-specific .deb package for k9s
curl -Lo ./tmp/k9s_linux.deb https://github.com/derailed/k9s/releases/download/v0.32.7/k9s_linux_${DISTRO}.deb
chmod +x ./tmp/k9s_linux.deb
sudo dpkg -i ./tmp/k9s_linux.deb
rm -rf tmp