#!/bin/bash
echo "Hey BOSS I HAZZ A KANZER!"
apt-get update && apt-get install -y \
  apt-transport-https ca-certificates curl software-properties-common gnupg2 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/debian \
  $(lsb_release -cs) \
  stable"

apt-get update && apt-get install -y \
  containerd.io \
  docker-ce \
  docker-ce-cli

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

systemctl daemon-reload
systemctl restart docker
sudo systemctl enable docker
echo -e "\e[32m-----------------Injecting modprobe-netfilter for Docker---------------]"
sudo modprobe br_netfilter
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
systemctl daemon-reload
systemctl restart kubelet
echo -e "\e[32m-----------Final service restart successful---------------------]"

