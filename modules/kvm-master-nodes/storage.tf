data "template_file" "user_data" {
  template = file("${path.module}/templates/cloud-init.cfg")
  vars = {
    hostname = var.name
    ssh-keys = var.ssh_key
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/templates/network-config.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "${var.name}-commoninit.iso"
  pool           = var.libvirt_pool.name
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
}

resource "libvirt_volume" "local_install_image" {
  name   = "${var.name}.qcow2"
  pool   = var.libvirt_pool.name
  source = var.image_base
  format = "qcow2"
}

resource "libvirt_volume" "node-disk-qcow2" {
  name = "${var.name}-disk-ubuntu-focal.qcow2"
  pool = var.libvirt_pool.name

  size = 1024 * 1024 * 1024 * var.disk_size

  base_volume_id   = libvirt_volume.local_install_image.id
  base_volume_pool = var.libvirt_pool.name

  format = "qcow2"
}
