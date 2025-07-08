variable "hcloud_token" {
  sensitive = true
}

variable "ssh_key" {
  # name of SSH key
}

variable "location" {
  default = "nbg1"
}

variable "private_ips" {
  type = object({
    name         = string
    ip_range     = string
    subnet_range = string
    network_zone = string
    controller = string
    worker     = string
  })
  default = {
    name         = "private_net"
    ip_range     = "10.0.0.0/16"
    subnet_range = "10.0.0.0/24"
    network_zone = "eu-central"
    controller = "10.0.0.11"
    worker     = "10.0.0.21"
  }
}

variable "my_ip" {}

variable "server" {
  type = object({
    type  = string
    image = string
  })
  default = {
    type  = "cpx11"
    image = "ubuntu-22.04"
  }
}
