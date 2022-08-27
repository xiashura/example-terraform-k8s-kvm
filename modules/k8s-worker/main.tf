

resource "null_resource" "k8s-get-credentials-join" {

  provisioner "local-exec" {
    command = <<EOF
      TOKEN=$(ssh -o StrictHostKeyChecking=no root@${var.master-node-host} sudo kubeadm token list | tail -1 | cut -f 1 -d " ") 
      HASH=$(ssh -o StrictHostKeyChecking=no root@${var.master-node-host} openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //' ) 
      echo "kubeadm join ${var.haproxy-node-host}:6443 --token $TOKEN --discovery-token-ca-cert-hash sha256:$HASH" > ${path.root}/tmp/script-worker-join.sh
    EOF
  }

}

resource "null_resource" "k8s-join-worker-nodes" {

  depends_on = [
    null_resource.k8s-get-credentials-join,
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = var.woker-node-host
  }

  provisioner "file" {
    source      = "${path.root}/tmp/script-worker-join.sh"
    destination = "/root/script-${var.woker-node-name}.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${var.hosts-master-nodes-domain}' >> /etc/hosts",
      # "echo '${var.master-node-host} ${var.master-node-name}' >> /etc/hosts",
      "bash /root/script-${var.woker-node-name}.sh",
    ]
  }

}
