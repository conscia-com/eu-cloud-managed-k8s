output "registry-url" {
  value = ovh_cloud_project_containerregistry.registry.url
}

output "user" {
  value = ovh_cloud_project_containerregistry_user.registry_user.user
}

output "password" {
  value     = ovh_cloud_project_containerregistry_user.registry_user.password
  sensitive = true
}