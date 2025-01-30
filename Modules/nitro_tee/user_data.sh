#!/bin/bash
set -euxo pipefail  

# Run as root but switch to ec2-user for setup
export HOME=/home/ec2-user

# Install critical dependencies first
sudo yum update -y
sudo yum install -y git curl jq

sudo -u ec2-user git clone "https://${GITHUB_TOKEN}@github.com/EternisAI/freysa-esper-private.git" /home/ec2-user/freysa-esper-private

# Run setup as ec2-user with full environment
sudo -i -u ec2-user bash <<'EOS'
  echo "Starting setup as $(whoami)"
  export PATH=$PATH:/usr/local/bin
  cd /home/ec2-user/freysa-esper-private/tee-tlsn
  chmod +x setup.sh
  ./setup.sh
  echo "Setup script exited with code $?"
EOS

# Configure nitro allocator
sudo tee /etc/nitro_enclaves/allocator.yaml <<EOF
---
memory_mib: 8192
cpu_count: 2
EOF
sudo systemctl restart nitro-enclaves-allocator.service

# Install gvproxy and start as service (I version locked this cause i was having issues with the automation using the Makefile)
sudo -i -u ec2-user /bin/bash <<'EOS'
  wget https://github.com/containers/gvisor-tap-vsock/releases/download/v0.8.2/gvproxy-linux-amd64
  chmod +x gvproxy-linux-amd64
  sudo mv gvproxy-linux-amd64 /usr/local/bin/gvproxy
EOS

echo "Starting gvproxy"
cd /home/ec2-user/freysa-esper-private/tee-tlsn
sudo ./gvproxy.sh

# Build and run TEE image
echo "Building and running TEE image"
sudo -i -u ec2-user /bin/bash -c <<'EOS'
  cd /home/ec2-user/freysa-esper-private/tee-tlsn
  make
EOS