output "ip" {
  value = libvirt_domain.kvm_node.*.network_interface.0.addresses
}


output "kvm_id" {
  value = libvirt_domain.kvm_node.id
}
