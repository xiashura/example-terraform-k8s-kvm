
resource "local_file" "kubeadm_file" {
  content = templatefile("${path.module}/template/kubeadm-config.yaml",
    {
      host     = var.ip_address
      ip_addrs = var.hosts-kubeadm-endpoints
      hosts    = var.hosts-kubeadm-certSANs
      count    = var.hosts-kubeadm-count-api
      name     = var.name
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
      "kubeadm init --config /root/kubadm.yaml"
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

resource "null_resource" "kubeadm-join-master-nodes" {

  count = var.first_master_node == "true" ? 0 : 1

  depends_on = [
    null_resource.kubeadm-init-master-node
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


  #join
  provisioner "remote-exec" {
    inline = [
      "kubeadm init --config /root/kubadm.yaml"
    ]
  }

}
