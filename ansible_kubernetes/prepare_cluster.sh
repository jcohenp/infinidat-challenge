#!/bin/bash


sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo echo overlay > /etc/modules-load.d/containerd.conf
sudo echo br_netfilter >> /etc/modules-load.d/containerd.conf
sudo modprobe overlay
sudo modprobe br_netfilter

cat << EOF > /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

echo 'KUBELET_EXTRA_ARGS="--cgroup-driver=cgroupfs"' > /etc/default/kubelet

sudo systemctl daemon-reload && sudo systemctl restart kubelet

cat << EOF > /etc/docker/daemon.json
{
      "exec-opts": ["native.cgroupdriver=systemd"],
      "log-driver": "json-file",
      "log-opts": {
      "max-size": "100m"
   },

       "storage-driver": "overlay2"
       }
EOF

sudo systemctl daemon-reload && sudo systemctl restart docker

sudo systemctl daemon-reload && sudo systemctl restart kubelet



