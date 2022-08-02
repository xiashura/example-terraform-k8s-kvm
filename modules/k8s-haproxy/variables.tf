variable "name" {
  description = "The name of the node"
}

variable "id_vm" {

}

variable "haproxy-node-host" {
  type = string
}

variable "master-nodes-host" {
  type = string
}


variable "id_dependsi" {
  default = "example"
}
