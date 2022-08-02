

resource "local_file" "etcd_service" {
  content = templatefile("${path.module}/template/etcd.service", {
    host  = var.ip_address
    hosts = var.hosts-etcd
  })
  filename = "${path.root}/tmp/${var.name}-etcd.service"
}


resource "null_resource" "etcd" {

  triggers = {
    id_dependsi = var.id_dependsi
  }

  depends_on = [
    local_file.etcd_service,
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = var.ip_address
  }

  provisioner "file" {
    source      = "${path.root}/tmp/${var.name}-etcd.service"
    destination = "/etc/systemd/system/etcd.service"
  }

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
      "systemctl daemon-reload",
      "systemctl enable etcd",
      "systemctl start etcd",
    ]
  }

}
