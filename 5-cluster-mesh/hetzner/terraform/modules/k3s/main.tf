terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.50"
    }
  }
}

resource "hcloud_server" "controller" {
  name        = var.name
  server_type = var.type
  image       = var.image
  location    = var.location
  ssh_keys    = [var.ssh_key]
  labels = {
    purpose = "kube_master_node"
  }
  network {
    network_id = var.network_id
    ip         = var.ip
  }
  user_data = var.user_data
}

resource "hcloud_server" "worker-node" {
  name        = "${var.name}-worker"
  server_type = var.type
  image       = var.image
  location    = var.location
  ssh_keys    = [var.ssh_key]
  labels = {
    purpose = "kube_worker_node"
  }
  network {
    network_id = var.network_id
    ip         = var.worker_ip
  }
  user_data = var.worker_user_data
  depends_on = [
    hcloud_server.controller
  ]
}
