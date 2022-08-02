variable "first_master_node" {
  type = string
}

variable "name" {
  description = "The name of the node"
}

variable "ip_address" {
  description = "10.223.1.2"
  type        = string
}

variable "hosts-kubeadm-endpoints" {
  description = "url list example [ https://10.223.1.2:2379 ]"
  type        = string
}


variable "hosts-kubeadm-certSANs" {
  description = ""
  type        = string
}

variable "hosts-kubeadm-count-api" {

}

variable "hosts-master-nodes-domain" {

}

variable "id_k8s_etcd_dependsi" {
  description = "dependsi id for apply kubeadm"
}

variable "id_haproxy_dependsi" {

}


variable "haproxy-node-host" {

}


variable "id_dependsi" {
  default = "example"
}
