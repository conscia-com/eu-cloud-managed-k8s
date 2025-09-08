resource "ovh_cloud_project_network_private" "net" {
  service_name = var.service_name
  name         = var.network.name
  regions      = [var.ovh_region]
}

locals {
  network_uuid = tolist(
    ovh_cloud_project_network_private.net.regions_attributes[*].openstackid
  )[0]
}

resource "ovh_cloud_project_network_private_subnet" "subnet" {
  service_name = var.service_name
  network_id   = ovh_cloud_project_network_private.net.id
  region       = var.ovh_region
  start        = var.network.start
  end          = var.network.end
  network      = var.network.network
  dhcp         = true
  no_gateway   = false
}

resource "ovh_cloud_project_gateway" "gateway" {
  service_name = var.service_name
  name         = "gateway"
  model        = var.network.gateway_model
  region       = var.ovh_region
  network_id   = local.network_uuid
  subnet_id    = ovh_cloud_project_network_private_subnet.subnet.id
}

resource "ovh_cloud_project_kube" "cluster" {
  service_name       = var.service_name
  name               = var.cluster.name
  region             = var.ovh_region
  version            = var.cluster.version
  private_network_id = local.network_uuid
  nodes_subnet_id    = ovh_cloud_project_network_private_subnet.subnet.id
  depends_on         = [ovh_cloud_project_gateway.gateway] //Gateway is mandatory for multizones cluster
}

resource "ovh_cloud_project_kube_nodepool" "node_pool" {
  service_name       = var.service_name
  kube_id            = ovh_cloud_project_kube.cluster.id
  name               = "${var.cluster.name}-nodepool"
  flavor_name        = var.cluster.node_type
  desired_nodes      = 1
  max_nodes          = 1
  min_nodes          = 1
  availability_zones = [var.ovh_az] //Currently, only one zone is supported per pool
}

data "ovh_cloud_project_capabilities_containerregistry_filter" "capabilities" {
  service_name = var.service_name
  plan_name    = var.registry_plan
  region       = var.ovh_region
}

resource "ovh_cloud_project_containerregistry" "registry" {
  service_name = data.ovh_cloud_project_capabilities_containerregistry_filter.capabilities.service_name
  plan_id      = data.ovh_cloud_project_capabilities_containerregistry_filter.capabilities.id
  region       = data.ovh_cloud_project_capabilities_containerregistry_filter.capabilities.region
  name         = "${var.cluster.name}-registry"
}

resource "ovh_cloud_project_containerregistry_user" "registry_user" {
  service_name = ovh_cloud_project_containerregistry.registry.service_name
  registry_id  = ovh_cloud_project_containerregistry.registry.id
  email        = var.registry_email
  login        = var.registry_user
}
