output "cluster_id" {
  value       = scaleway_k8s_cluster.cluster.id
  description = "ID of the Kubernetes Cluster"
}

output "cluster_name" {
  value       = scaleway_k8s_cluster.cluster.name
  description = "Name of the Kubernetes Cluster"
}