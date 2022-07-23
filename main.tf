

provider "libvirt" {
  uri   = "qemu:///system"
  alias = "local"
}

module "kvm-resources-nodes" {
  source = "./modules/kvm-resources-nodes"
  providers = {
    libvirt = libvirt.local
  }
}

module "kvm-master-nodes" {
  source = "./modules/kvm-master-nodes"
  count  = length(local.hosts-master-nodes)

  name       = local.hosts-master-nodes[count.index].name
  memory     = local.hosts-master-nodes[count.index].memory
  vcpu       = local.hosts-master-nodes[count.index].vcpu
  disk_size  = local.hosts-master-nodes[count.index].disk_size
  image_base = var.image_base_k8s
  ssh_key    = var.sshkey-nixos-thinkpad

  libvirt_pool    = module.kvm-resources-nodes.libvirt_pool
  libvirt_network = module.kvm-resources-nodes.libvirt_network

  providers = {
    libvirt = libvirt.local
  }
}


module "config" {

  source = "cloudposse/config/yaml"

  map_config_local_base_path = "./resources"

  map_config_paths = [
    "main.yaml",
  ]
}
