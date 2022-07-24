resource "libvirt_pool" "hosts" {
  name = "hosts"
  type = "dir"
  path = var.path
}

resource "libvirt_network" "hosts_net" {
  name      = "hosts_net"
  addresses = var.addresses

  mode      = "nat"
  domain    = var.dns_domain
  autostart = true
  dns {
    enabled    = true
    local_only = false

    forwarders { address = "127.0.0.53" }

    dynamic "hosts" {
      for_each = var.hosts_nodes
      content {
        hostname = hosts.value.hostname
        ip       = hosts.value.ip
      }
    }


  }

  routes {
    cidr    = var.addresses.0
    gateway = var.gw_address
  }

  dhcp {
    enabled = false
  }
}


