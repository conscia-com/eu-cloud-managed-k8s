module "cluster1" {
  source           = "./modules/k3s"
  name             = "cluster1"
  type             = var.server.type
  image            = var.server.image
  ssh_key          = var.ssh_key
  location         = var.location
  network_id       = hcloud_network.private_net.id
  ip               = var.private_ips.cluster1
  worker_ip        = var.private_ips.cluster1_worker
  user_data        = file("./cloud-init/cluster1_controller.yaml")
  worker_user_data = file("./cloud-init/cluster1_worker.yaml")
  depends_on = [
    hcloud_network_subnet.private_subnet
  ]
}

module "cluster2" {
  source     = "./modules/k3s"
  name       = "cluster2"
  type       = var.server.type
  image      = var.server.image
  ssh_key    = var.ssh_key
  location   = var.location
  network_id = hcloud_network.private_net.id
  ip         = var.private_ips.cluster2
  worker_ip  = var.private_ips.cluster2_worker
  user_data  = file("./cloud-init/cluster2_controller.yaml")
  worker_user_data = file("./cloud-init/cluster2_worker.yaml")
  depends_on = [
    hcloud_network_subnet.private_subnet
  ]
}
