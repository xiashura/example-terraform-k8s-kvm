
resource "local_file" "kubeadm_file" {
  content = templatefile("${path.module}/template/kubeadm-config.yaml",
    {
      host     = var.ip_address
      ip_addrs = var.hosts-kubeadm-endpoints
      # hosts    = var.hosts-kubeadm-certSANs
      haproxy-host = var.haproxy-node-host
      count        = var.hosts-kubeadm-count-api
      name         = var.name
  })
  filename = "${path.root}/tmp/${var.name}-kubeadm.yaml"
}



resource "null_resource" "kubeadm-init-master-node" {

  count = var.first_master_node == "true" ? 1 : 0

  depends_on = [
    local_file.kubeadm_file,
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = var.ip_address
  }

  provisioner "file" {
    source      = "${path.root}/tmp/${var.name}-kubeadm.yaml"
    destination = "/root/kubadm.yaml"
  }

  #init kubeadm
  provisioner "remote-exec" {
    inline = [
      "kubeadm init --config /root/kubadm.yaml",
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
    ]

  }
  provisioner "local-exec" {
    command = "mkdir -p ${path.root}/tmp/etc/kubernetes"
  }


  #scp cert
  provisioner "local-exec" {
    command = "rsync -Wav -e 'ssh -o StrictHostKeyChecking=no' root@${var.ip_address}:/etc/kubernetes/pki ${path.root}/tmp/etc/kubernetes"
  }

}

resource "null_resource" "kubeadm-cammand-join-nodes" {

  depends_on = [
    null_resource.kubeadm-init-master-node,
  ]

  count = var.first_master_node == "true" ? 1 : 0
  provisioner "local-exec" {
    command = <<EOF
      TOKEN=$(ssh -o StrictHostKeyChecking=no root@${var.ip_address} sudo kubeadm token list | tail -1 | cut -f 1 -d " ") 
      HASH=$(ssh -o StrictHostKeyChecking=no root@${var.ip_address} openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //' ) 
      echo "kubeadm join ${var.haproxy-node-host}:6443 --token $TOKEN --discovery-token-ca-cert-hash sha256:$HASH" --control-plane > ${path.root}/tmp/script-master-join.sh
    EOF
  }


  provisioner "local-exec" {
    command = <<EOF
      TOKEN=$(ssh -o StrictHostKeyChecking=no root@${var.ip_address} sudo kubeadm token list | tail -1 | cut -f 1 -d " ") 
      HASH=$(ssh -o StrictHostKeyChecking=no root@${var.ip_address} openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //' ) 
      echo "kubeadm join ${var.haproxy-node-host}:6443 --token $TOKEN --discovery-token-ca-cert-hash sha256:$HASH" > ${path.root}/tmp/script-worker-join.sh
    EOF
  }
}


resource "null_resource" "kubeadm-join-master-nodes" {

  count = var.first_master_node == "true" ? 0 : 1

  triggers = {
    id_dependsi = var.id_dependsi
  }

  depends_on = [
    null_resource.kubeadm-cammand-join-nodes,
    null_resource.kubeadm-init-master-node,
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = var.ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/kubernetes/pki"
    ]
  }

  #scp pki kubernetes
  provisioner "file" {
    source      = "${path.root}/tmp/etc/kubernetes/pki/"
    destination = "/etc/kubernetes/pki"
  }


  provisioner "file" {
    source      = "${path.root}/tmp/script-master-join.sh"
    destination = "/root/script-master-join.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${var.hosts-master-nodes-domain}' >> /etc/hosts",
    ]
  }


  #join
  provisioner "remote-exec" {
    inline = [
      "rm /etc/kubernetes/pki/apiserver.*",
      "bash /root/script-master-join.sh",
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/kubelet.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
    ]
  }

}
