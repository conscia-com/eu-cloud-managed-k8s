resource "scaleway_vpc_private_network" "pn" {
  name   = "${var.name}-private-network"
  region = var.region
  ipv4_subnet {
    subnet = var.pn_cidr
  }
}

resource "scaleway_k8s_cluster" "cluster" {
  name                        = "${var.name}-cluster"
  type                        = var.cluster.type
  version                     = var.cluster.version
  cni                         = var.cluster.cni
  private_network_id          = scaleway_vpc_private_network.pn.id
  delete_additional_resources = true
}

resource "scaleway_k8s_acl" "cluster_acl" {
  cluster_id = scaleway_k8s_cluster.cluster.id
  acl_rules {
    ip          = var.trusted_ip
    description = "Allow access from trusted IP"
  }
  acl_rules {
    scaleway_ranges = true
    description     = "Allow all Scaleway ranges"
  }
}

resource "scaleway_k8s_pool" "pool" {
  cluster_id  = scaleway_k8s_cluster.cluster.id
  name        = "${var.name}-pool"
  node_type   = var.cluster.node_type
  size        = 1
  min_size    = 0
  max_size    = 1
  autoscaling = true
  autohealing = true
}

resource "random_id" "unique" {
  byte_length = 4
}

resource "scaleway_registry_namespace" "registry" {
  name      = "sandbox-${random_id.unique.hex}"
  is_public = false
}
