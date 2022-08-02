# output "id_dependsi_init_master" {
#   value = null_resource.kubeadm-init-master-node.*.id
# }


output "id_dependsi_join_master" {
  value = null_resource.kubeadm-join-master-nodes.*.triggers.id_dependsi
}
