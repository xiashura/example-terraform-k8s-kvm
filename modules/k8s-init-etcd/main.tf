
resource "null_resource" "init_kubeadm" {

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = var.host
  }

  provisioner "remote-exec" {
    inline = [
      # "kubeadm init --control-plane-endpoint "LOAD_BALANCER_DNS:LOAD_BALANCER_PORT" --upload-certs --pod-network-cidr=192.168.0.0/16 "
      "echo test",
      "echo test > example.txt",
    ]
  }

}
