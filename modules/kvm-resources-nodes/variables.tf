
variable "path" {
  description = "path to libvirt pool"
  default     = "/tmp/terraform_hosts"
}

variable "addresses" {
  default = ["10.223.1.0/24"]
}
