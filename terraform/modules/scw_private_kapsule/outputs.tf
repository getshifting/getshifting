output "cluster_id" {
  value = scaleway_k8s_cluster.this.id
}

output "kubeconfig" {
  value     = scaleway_k8s_cluster.this.kubeconfig
  sensitive = true
}

output "api_url" {
  value = scaleway_k8s_cluster.this.apiserver_url
}

output "pool_id" {
  value = scaleway_k8s_pool.this.id
}
