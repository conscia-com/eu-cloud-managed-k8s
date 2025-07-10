resource "hcloud_network" "private_net" {
  name     = var.private_ips.name
  ip_range = var.private_ips.ip_range
  labels = {
    name = var.private_ips.name
  }
}

resource "hcloud_network_subnet" "private_subnet" {
  network_id   = hcloud_network.private_net.id
  type         = "server"
  network_zone = var.private_ips.network_zone
  ip_range     = var.private_ips.subnet_range
}
