variable "hcloud_token" {
  sensitive = true
}

variable "ssh_key" {
  default = "tcloud"
}

variable "location" {
  default = "nbg1"
}

variable "private_ips" {
  type = object({
    name            = string
    ip_range        = string
    subnet_range    = string
    network_zone    = string
    controller      = string
    cluster1        = string
    cluster1_worker = string
    cluster2        = string
    cluster2_worker = string
  })
  default = {
    name            = "private_net"
    ip_range        = "10.0.0.0/16"
    subnet_range    = "10.0.0.0/24"
    network_zone    = "eu-central"
    controller      = "10.0.0.11"
    cluster1        = "10.0.0.21"
    cluster1_worker = "10.0.0.22"
    cluster2        = "10.0.0.31"
    cluster2_worker = "10.0.0.32"
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
