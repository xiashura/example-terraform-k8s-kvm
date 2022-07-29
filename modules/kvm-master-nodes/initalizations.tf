

data "template_file" "etcd_service_file" {
  template = file("${path.module}/templates/etcd.service")
  vars = {
    host  = var.ip_address
    hosts = var.hosts-etcd
  }
}

resource "null_resource" "etcd" {


  depends_on = [
    libvirt_domain.kvm_node,
  ]


  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = var.ip_address
  }


  # provisioner "remote-exec" {
  #   inline = [
  #     "wget https://github.com/etcd-io/etcd/releases/download/v3.4.13/etcd-v3.4.13-linux-amd64.tar.gz -O /root/etcd-amd64.tar.gz",
  #     "tar xvzf /root/etcd-amd64.tar.gz -C /root/",
  #     "mv /root/etcd-v3.4.13-linux-amd64/etcd /usr/local/bin/etcd",
  #     "mv /root/etcd-v3.4.13-linux-amd64/etcdctl /usr/local/bin/etcdctl",

  #   ]
  # }


  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/etcd"
    ]
  }

  provisioner "file" {
    source      = "${path.root}/k8s/cert/ca.pem"
    destination = "/etc/etcd/ca.pem"
  }


  provisioner "file" {
    source      = "${path.root}/k8s/cert/kubernetes.pem"
    destination = "/etc/etcd/kubernetes.pem"
  }


  provisioner "file" {
    source      = "${path.root}/k8s/cert/kubernetes-key.pem"
    destination = "/etc/etcd/kubernetes-key.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "cat << EOF > /etc/systemd/system/etcd.service\n${data.template_file.etcd_service_file.rendered}\nEOF"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl enable etcd",
      "systemctl start etcd"
    ]
  }


}
