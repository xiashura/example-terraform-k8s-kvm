variable "name" {
  description = "The name of the node"
}

variable "ip_address" {
  description = "ip sub mask"
}

variable "hosts-etcd" {
  description = "urls etcd example 192.168.1.113=https://192.168.1.113:2380,192.168.1.114=https://192.168.1.114:2380,192.168.1.115=https://192.168.1.115:2380"
  type        = string
}

variable "id_vm" {

}

variable "id_dependsi" {
  default = "example"
}


