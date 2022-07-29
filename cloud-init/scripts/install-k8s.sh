#!/bin/bash -x

apt-get update && apt-get install -y \
  apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

apt-get update && apt-get install -y \
  containerd.io=1.2.10-3 \
  docker-ce=5:19.03.4~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:19.03.4~3-0~ubuntu-$(lsb_release -cs)

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

rm /etc/containerd/config.toml
systemctl restart containerd

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

systemctl daemon-reload
systemctl restart kubelet

kubeadm config images pull


export RELEASE_ETCD=$(curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest|grep tag_name | cut -d '"' -f 4)
wget https://github.com/etcd-io/etcd/releases/download/${RELEASE_ETCD}/etcd-${RELEASE_ETCD}-linux-amd64.tar.gz
tar xvf etcd-${RELEASE_ETCD}-linux-amd64.tar.gz
sudo mv ./etcd-${RELEASE_ETCD}-linux-amd64/etcd ./etcd-${RELEASE_ETCD}-linux-amd64/etcdctl /usr/local/bin 

sed -i -e 's/#DNS=/DNS=8.8.8.8/g' /etc/systemd/resolved.conf 
systemctl restart systemd-resolved

swapoff -a
apt autoclean
rm -Rf /var/cache/apt/*