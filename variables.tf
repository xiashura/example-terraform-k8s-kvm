
variable "image_base_k8s" {
  type    = string
  default = "build/master-node/master-node.qcow2"

}

variable "image_base_loadbalancer" {
  default = "build/loadbalancer-node/loadbalancer-node.qcow2"
}

locals {

  hosts-haproxy-node = yamldecode(file("${path.module}/resources/loadbalancer-node/loadbalancer-node.yaml"))


  hosts-master-nodes = concat(
    var.hosts-master-nodes,
    yamldecode(file("${path.module}/resources/master-nodes/master-node-1.yaml", )),
    yamldecode(file("${path.module}/resources/master-nodes/master-node-2.yaml", ))
  )

  hosts-worker-nodes = concat(
    var.hosts-worker-nodes,
    yamldecode(file("${path.module}/resources/worker-nodes/worker-node-1.yaml", )),
    yamldecode(file("${path.module}/resources/worker-nodes/worker-node-2.yaml", )),
  )

  hosts_nodes = concat(
    var.hosts_nodes,

    yamldecode(file("${path.module}/resources/master-nodes/master-node-1.yaml", )),
    yamldecode(file("${path.module}/resources/master-nodes/master-node-2.yaml", ))
  )


}

variable "sshkey-nixos-server" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQClAa1q27xKavfjBrWxpIegUHVaaUg9ud/8ugw4FL6z3dqHnyaeRk1S/G4tZ/pvxo+KPkNHwd1GGQ/YJKg5ssof1t0Ax+y3+d4oGHCsVqyLjnKGhUvLKuBW2yclH+IUTYfwuv8TchvC6zOiN+IynU9/3Vlk/RqxP7cULykggqtBk5FKhsIwz32hzvBoZD/Ne/xeXZxDc/JCjGNde1wiRKEpZ+C0xs4uqLlh54lOdqY5QlVqO+Ou2vxBhoNGG9D3SARxcTLkOPu1NYtUblcJANXsWYgsAsak3FTXreLzRct8rovWMjDx86xa3RVdbLmODVdLOb2++k+qWefnAoNFin+eYCjMuviwF/3FG31KcYhe0wgKDtxi6Nm8qfoGQax9FsKL1lqi3EaEJM6W0XQCXOvDBOj5blv0cIVEZki4TJdL7BX3tQcOwXstA4ogENirnfpoRU5FcHiKw0Gre42yqT2KlOnZibE6IsOZwFz4t3qffaMTNFSnWcSixKnKIwIfjQs= xi@nixos"
}

variable "sshkey-nixos-thinkpad" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQClAa1q27xKavfjBrWxpIegUHVaaUg9ud/8ugw4FL6z3dqHnyaeRk1S/G4tZ/pvxo+KPkNHwd1GGQ/YJKg5ssof1t0Ax+y3+d4oGHCsVqyLjnKGhUvLKuBW2yclH+IUTYfwuv8TchvC6zOiN+IynU9/3Vlk/RqxP7cULykggqtBk5FKhsIwz32hzvBoZD/Ne/xeXZxDc/JCjGNde1wiRKEpZ+C0xs4uqLlh54lOdqY5QlVqO+Ou2vxBhoNGG9D3SARxcTLkOPu1NYtUblcJANXsWYgsAsak3FTXreLzRct8rovWMjDx86xa3RVdbLmODVdLOb2++k+qWefnAoNFin+eYCjMuviwF/3FG31KcYhe0wgKDtxi6Nm8qfoGQax9FsKL1lqi3EaEJM6W0XQCXOvDBOj5blv0cIVEZki4TJdL7BX3tQcOwXstA4ogENirnfpoRU5FcHiKw0Gre42yqT2KlOnZibE6IsOZwFz4t3qffaMTNFSnWcSixKnKIwIfjQs= xi@nixos"
}

variable "hosts_nodes" {
  type = list(object({
    hostname = string
    ip       = string
  }))
  default = []
}

variable "gw_address" {
  type    = string
  default = "10.223.1.1"
}
variable "addresses" {
  type    = list(string)
  default = ["10.223.1.0/24"]

}
variable "dns_domain" {
  type    = string
  default = "dns_domain"
}

variable "hosts-master-nodes" {
  type = list(object({
    name   = string
    ip     = string
    source = string
    memory = string
    vcpu   = number
    size   = number
    first  = string
    configuration = object({
      name     = string
      passwd   = string
      ssh-keys = list(string)
    })
  }))
  default = []
}

variable "hosts-haproxy-node" {
  type = list(object({
    name   = string
    ip     = string
    source = string
    memory = string
    vcpu   = number
    size   = number
    configuration = object({
      name     = string
      passwd   = string
      ssh-keys = list(string)
    })
  }))
  default = []
}

variable "hosts-worker-nodes" {
  type = list(object({
    name             = string
    ip               = string
    master-node-ip   = string
    master-node-name = string
    source           = string
    memory           = string
    vcpu             = number
    size             = number
    configuration = object({
      name     = string
      passwd   = string
      ssh-keys = list(string)
    })
  }))
  default = []
}



variable "hosts" {
  type = list(object({
    name   = string
    ip     = string
    source = string
    memory = string
    vcpu   = number
    size   = number
    configuration = object({
      name     = string
      passwd   = string
      ssh-keys = list(string)
    })
  }))
  default = []
}







