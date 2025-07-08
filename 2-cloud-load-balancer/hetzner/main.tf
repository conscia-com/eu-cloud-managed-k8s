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

resource "hcloud_server" "controller" {
  name        = "controller"
  server_type = var.server.type
  image       = var.server.image
  location    = var.location
  ssh_keys    = [var.ssh_key]
  labels = {
    purpose = "kube_master_node"
  }
  network {
    network_id = hcloud_network.private_net.id
    ip         = var.private_ips.controller
  }
  user_data = file("./cloud-init/controller.yaml")
  depends_on = [
    hcloud_network_subnet.private_subnet
  ]
}

resource "hcloud_server" "worker-node" {
  name        = "worker-node"
  server_type = var.server.type
  image       = var.server.image
  location    = var.location
  ssh_keys    = [var.ssh_key]
  labels = {
    purpose = "kube_worker_node"
  }
  network {
    network_id = hcloud_network.private_net.id
    ip         = var.private_ips.worker
  }
  user_data = file("./cloud-init/worker.yaml")
  depends_on = [
    hcloud_network_subnet.private_subnet,
    hcloud_server.controller
  ]
}

resource "hcloud_firewall" "kube" {
  name = "kube"
  rule {
    direction  = "in"
    port       = "6443"
    protocol   = "tcp"
    source_ips = ["${var.my_ip}/32"]
  }
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "30000-32767"
    source_ips = ["0.0.0.0/0"] # Or limit to Hetzner LB IPs
  }
  rule {
    direction  = "in"
    port       = "22"
    protocol   = "tcp"
    source_ips = ["${var.my_ip}/32"]
  }
  rule {
    direction = "in"
    port      = "any"
    protocol  = "tcp"
    source_ips = [
      hcloud_server.worker-node.ipv4_address,
      hcloud_server.controller.ipv4_address
    ]
  }
}

resource "hcloud_firewall_attachment" "kube_attachment" {
  firewall_id = hcloud_firewall.kube.id
  server_ids  = [hcloud_server.worker-node.id, hcloud_server.controller.id]
}
