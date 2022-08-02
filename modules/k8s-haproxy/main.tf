
resource "local_file" "haproxy_config" {
  content = templatefile("${path.module}/template/haproxy.cfg", {
    ip_address = var.haproxy-node-host
    hosts      = var.master-nodes-host
  })
  filename = "${path.root}/tmp/${var.name}-haproxy.cfg"
}

resource "null_resource" "haproxy" {

  triggers = {
    id_dependsi = var.id_dependsi
  }

  depends_on = [
    local_file.haproxy_config,
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = var.haproxy-node-host
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/haproxy",
    ]
  }

  provisioner "file" {
    source      = "${path.root}/tmp/${var.name}-haproxy.cfg"
    destination = "/etc/haproxy/haproxy.cfg"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl enable haproxy",
      "systemctl restart haproxy"
    ]
  }

}
