
variable "path" {
  description = "path to libvirt pool"
  default     = "/tmp/terraform_hosts"
}

variable "addresses" {
  default = ["10.223.1.0/24"]
}

variable "dns_domain" {
  description = "DNS domain name"
  default     = "localdomain"
}

variable "gw_address" {
  description = "IP address of the gateway"
  default     = "10.223.1.1"
}

variable "hosts_nodes" {
  type = list(object({
    hostname = string
    ip       = string
  }))
  default = []
}
