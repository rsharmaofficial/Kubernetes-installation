#!/bin/bash

# Update the system
sudo yum update -y

# Install Docker
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io

# Enable and start Docker
sudo systemctl enable --now docker

# Disable SELinux (optional but recommended for kubeadm setup)
sudo setenforce 0
sudo sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# Disable Swap (kubeadm requirement)
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Add Kubernetes repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
EOF

# Install Kubernetes components
sudo yum install -y kubelet-1.28.1 kubeadm-1.28.1 kubectl-1.28.1

# Enable and start kubelet
sudo systemctl enable --now kubelet

echo "✅ Installation complete. Reboot recommended before running 'kubeadm init'"
