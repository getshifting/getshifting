module "private_kapsule" {
  source                      = "../../modules/scw_private_kapsule"
  name                        = "k8s-ams"
  cluster_type                = "kapsule"
  kubernetes_version          = "1.35.3"
  region                      = var.region
  zone                        = var.zone
  allowed_ip_ranges           = [var.my_ip_address]
  delete_additional_resources = true

  # Network configuration
  cni                = "cilium"
  private_network_id = module.private_network_k8s.id
  pod_cidr           = "100.64.0.0/15"
  service_cidr       = "100.100.0.0/23"
  service_dns_ip     = "100.100.0.10"

  # Pool configuration
  pool_name                   = "pool-ams1"
  pool_node_type              = "basic3_x2c_4g"
  pool_root_volume_size_in_gb = 20
  pool_size                   = 1
  pool_min_size               = 1
  pool_max_size               = 2

  depends_on = [module.public_gateway]
}
