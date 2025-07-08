resource "ovh_cloud_project_kube" "cluster" {
  service_name = var.service_name
  name         = var.cluster.name
  region       = var.ovh_region
  version      = var.cluster.version
}

resource "ovh_cloud_project_kube_nodepool" "node_pool" {
  service_name  = var.service_name
  kube_id       = ovh_cloud_project_kube.cluster.id
  name          = "${var.cluster.name}-pool" //Warning: "_" char is not allowed!
  flavor_name   = var.cluster.node_type
  desired_nodes = 1
  max_nodes     = 1
  min_nodes     = 1
}

data "ovh_cloud_project_capabilities_containerregistry_filter" "capabilities" {
  service_name = var.service_name
  plan_name    = var.registry.plan
  region       = var.registry.region
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
