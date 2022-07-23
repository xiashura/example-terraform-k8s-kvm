
resource "libvirt_domain" "kvm_node" {
  name = var.name

  memory = var.memory
  vcpu   = var.vcpu

  qemu_agent = true
  autostart  = true

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_id = var.libvirt_network.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.node-disk-qcow2.id
  }
}
