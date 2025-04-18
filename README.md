# Kubernetes Setup on AWS EC2 (RHEL) - Two Node Cluster

This repository demonstrates how to set up a basic Kubernetes (K8s) cluster using kubeadm on two EC2 instances running **Red Hat Enterprise Linux (RHEL)** — one as **Master**, the other as **Worker**.

---

## ✨ Overview

We will:
- Install Docker
- Add Kubernetes GPG keys and repository
- Install kubeadm, kubelet, and kubectl
- Initialize the Master node
- Join the Worker node
- Verify the cluster

---

## 📄 Prerequisites

- AWS account
- 2 EC2 Instances with RHEL 8+ (t2.medium or higher recommended)
- Inbound ports: 22, 6443, 10250, 30000-32767
- SSH access

---

## 🚀 Step-by-Step Installation

### 🔍 SSH into EC2

```bash
ssh -i <your-key.pem> ec2-user@<public-ip>
```

### 📁 Create and Run Script

Create an install script on both instances:

```bash
vi install-k8s-rhel.sh
```

Paste the following:

```bash
#!/bin/bash

set -e

# Docker Installation
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
systemctl enable --now docker

# Kubernetes Repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Install K8s
yum install -y kubelet-1.28.1 kubeadm-1.28.1 kubectl-1.28.1 --disableexcludes=kubernetes
systemctl enable --now kubelet

# Disable swap
swapoff -a
sed -i '/swap/d' /etc/fstab
```

Make the script executable and run:

```bash
chmod +x install-k8s-rhel.sh
./install-k8s-rhel.sh
```

### 📖 Initialize Master Node (only on master)

```bash
kubeadm init --pod-network-cidr=192.168.0.0/16
```

Set up `kubectl` config:

```bash
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```

### 🔗 Join Worker Node

Copy the `kubeadm join` command from the master output and run it on the worker node.

---

## 🌐 Networking (CNI Plugin)

Install a CNI plugin like Flannel:

```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

---

## 🔍 Verify Cluster

```bash
kubectl get nodes
kubectl get pods -A
```

---

## 📸 Screenshots

### EC2 Master Instance Summary
![EC2 Master Instance Summary](https://github.com/rsharmaofficial/Kubernetes-installation/blob/main/Screenshot%202025-04-19%20003345.png)

### Installation Script Outputs
5 consecutive screenshots showing the install script execution on RHEL-based EC2 instances:

![Install Step 1](Screenshot-2025-04-19-003345.png)

![Install Step 2](Screenshot-2025-04-19-003403.png)

![Install Step 3](Screenshot-2025-04-19-003416.png)

![Install Step 4](Screenshot-2025-04-19-003428.png)

![Install Step 5](Screenshot-2025-04-19-003441.png)

