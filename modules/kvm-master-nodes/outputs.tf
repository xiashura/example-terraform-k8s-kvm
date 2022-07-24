output "ip" {
  value = libvirt_domain.kvm_node.*.network_interface.0.addresses
}
