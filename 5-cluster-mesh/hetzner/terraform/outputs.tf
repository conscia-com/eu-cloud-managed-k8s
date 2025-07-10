output "cluster1_pip" {
  value       = module.cluster1.pip
  description = "Cluster 1 Server IP"
}

output "cluster2_pip" {
  value       = module.cluster2.pip
  description = "Cluster 2 Server IP"
}