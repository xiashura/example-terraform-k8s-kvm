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

module "kvm-loadbalancer-node" {
  source     = "./modules/kvm-loadbalancer-node"
  name       = local.hosts-haproxy-node.name
  memory     = local.hosts-haproxy-node.memory
  vcpu       = local.hosts-haproxy-node.vcpu
  disk_size  = local.hosts-haproxy-node.disk_size
  ip_address = local.hosts-haproxy-node.ip

  image_base = var.image_base_loadbalancer
  ssh_key    = var.sshkey-nixos-thinkpad

  gw_address      = var.gw_address
  dns_domain      = var.dns_domain
  libvirt_pool    = module.kvm-resources-nodes.libvirt_pool
  libvirt_network = module.kvm-resources-nodes.libvirt_network

  providers = {
    libvirt = libvirt.remote
  }
}

module "k8s-haproxy" {
  source = "./modules/k8s-haproxy"

  name              = local.hosts-haproxy-node.name
  id_vm             = module.kvm-loadbalancer-node.kvm_id
  haproxy-node-host = local.hosts-haproxy-node.ip
  master-nodes-host = join(
    ",",
    [for s in local.hosts-master-nodes : format("%s", s.ip)],
  )
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
  hosts-master-nodes-domain = join(
    "\n",
    [for s in local.hosts-master-nodes : format("%s %s", s.ip, s.name)],
  )

  hosts-kubeadm-count-api = length(local.hosts-master-nodes)
  count                   = length(local.hosts-master-nodes)

  id_k8s_etcd_dependsi = module.k8s-etcd[count.index].id_dependsi
  id_haproxy_dependsi  = module.k8s-haproxy.id_dependsi
  ip_address           = local.hosts-master-nodes[count.index].ip
  name                 = local.hosts-master-nodes[count.index].name
  first_master_node    = local.hosts-master-nodes[count.index].first
  haproxy-node-host    = local.hosts-haproxy-node.ip
}

module "kvm-worker-nodes" {
  source = "./modules/kvm-worker-nodes"
  count  = length(local.hosts-worker-nodes)

  name       = local.hosts-worker-nodes[count.index].name
  memory     = local.hosts-worker-nodes[count.index].memory
  vcpu       = local.hosts-worker-nodes[count.index].vcpu
  disk_size  = local.hosts-worker-nodes[count.index].disk_size
  ip_address = local.hosts-worker-nodes[count.index].ip

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

module "k8s-worker" {
  source = "./modules/k8s-worker"

  count = length(local.hosts-worker-nodes)

  id_dependsi_join_master = module.k8s-kubeadm[0].id_dependsi_join_master
  id_vm                   = module.kvm-worker-nodes[count.index].kvm_id

  woker-node-name = local.hosts-worker-nodes[count.index].name
  woker-node-host = local.hosts-worker-nodes[count.index].ip

  master-node-name = local.hosts-master-nodes[0].name
  master-node-host = local.hosts-master-nodes[0].ip


  hosts-master-nodes-domain = join(
    "\n",
    [for s in local.hosts-master-nodes : format("%s %s", s.ip, s.name)],
  )
  haproxy-node-host = local.hosts-haproxy-node.ip
}
