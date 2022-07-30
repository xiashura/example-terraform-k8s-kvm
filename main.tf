provider "libvirt" {
  uri   = "qemu:///system"
  alias = "remote"
}

module "config" {

  source = "cloudposse/config/yaml"

  map_config_local_base_path = "./resources"

  map_config_paths = [
    "main.yaml",
  ]
}


module "init-cert" {
  source    = "./modules/k8s-init-cert"
  addresses = join(",", [for s in local.hosts_nodes : format("%s", s.ip)])
}


module "kvm-resources-nodes" {
  source = "./modules/kvm-resources-nodes"

  addresses  = var.addresses
  gw_address = var.gw_address
  dns_domain = var.dns_domain

  hosts_nodes = var.hosts_nodes

  providers = {
    libvirt = libvirt.remote
  }
}

module "kvm-master-nodes" {
  source = "./modules/kvm-master-nodes"
  count  = length(local.hosts-master-nodes)

  name       = local.hosts-master-nodes[count.index].name
  memory     = local.hosts-master-nodes[count.index].memory
  vcpu       = local.hosts-master-nodes[count.index].vcpu
  disk_size  = local.hosts-master-nodes[count.index].disk_size
  ip_address = local.hosts-master-nodes[count.index].ip

  image_base = var.image_base_k8s
  ssh_key    = var.sshkey-nixos-thinkpad


  gw_address      = var.gw_address
  dns_domain      = var.dns_domain
  libvirt_pool    = module.kvm-resources-nodes.libvirt_pool
  libvirt_network = module.kvm-resources-nodes.libvirt_network
  providers = {
    libvirt = libvirt.remote
  }
}

module "k8s-etcd" {
  source = "./modules/k8s-etcd"

  hosts-etcd = join(",", [for s in local.hosts-master-nodes : format("%s=https://%s:2380", s.ip, s.ip)])

  count = length(local.hosts-master-nodes)

  id_vm      = module.kvm-master-nodes[count.index].kvm_id
  ip_address = local.hosts-master-nodes[count.index].ip
  name       = local.hosts-master-nodes[count.index].name
}


module "k8s-kubeadm" {
  source = "./modules/k8s-kubeadm"

  hosts-kubeadm-endpoints = join(
    ",",
    [for s in local.hosts-master-nodes : format("https://%s:2379", s.ip)],
  )
  hosts-kubeadm-certSANs = join(
    ",",
    [for s in local.hosts-master-nodes : format("%s", s.name)],
  )
  hosts-kubeadm-count-api = length(local.hosts-master-nodes)
  count                   = length(local.hosts-master-nodes)

  id_k8s_etcd       = module.k8s-etcd[count.index].id_dependsi
  ip_address        = local.hosts-master-nodes[count.index].ip
  name              = local.hosts-master-nodes[count.index].name
  first_master_node = local.hosts-master-nodes[count.index].first
}
