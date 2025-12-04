resource "digitalocean_kubernetes_cluster" "workers" {
  name    = "saturnci-workers-cluster"
  region  = "nyc2"
  version = "1.32.10-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-4vcpu-8gb"
    node_count = 2
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 10
  }
}

output "workers_cluster_id" {
  value = digitalocean_kubernetes_cluster.workers.id
}

output "workers_kubeconfig" {
  value     = digitalocean_kubernetes_cluster.workers.kube_config[0].raw_config
  sensitive = true
}
