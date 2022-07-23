resource "libvirt_pool" "hosts" {
  name = "hosts"
  type = "dir"
  path = var.path
}

resource "libvirt_network" "hosts_net" {
  name      = "hosts_net"
  addresses = var.addresses

  dns {
    enabled = true
  }

  dhcp {
    enabled = true
  }
}
