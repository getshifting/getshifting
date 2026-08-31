terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
}

resource "scaleway_k8s_cluster" "this" {
  name                        = var.name
  version                     = var.kubernetes_version
  cni                         = var.cni
  region                      = var.region
  type                        = var.cluster_type
  private_network_id          = var.private_network_id
  pod_cidr                    = var.pod_cidr
  service_cidr                = var.service_cidr
  service_dns_ip              = var.service_dns_ip
  delete_additional_resources = var.delete_additional_resources

  autoscaler_config {
    disable_scale_down = false
  }

  auto_upgrade {
    enable                        = false
    maintenance_window_start_hour = 3
    maintenance_window_day        = "any"
  }
}

resource "scaleway_k8s_pool" "this" {
  cluster_id             = scaleway_k8s_cluster.this.id
  name                   = var.pool_name
  node_type              = var.pool_node_type
  region                 = var.region
  zone                   = var.zone
  size                   = var.pool_size
  min_size               = var.pool_min_size
  max_size               = var.pool_max_size
  autoscaling            = true
  autohealing            = true
  public_ip_disabled     = true
  root_volume_size_in_gb = var.pool_root_volume_size_in_gb
  root_volume_type       = "sbs_5k"

  lifecycle {
    ignore_changes = [
      root_volume_size_in_gb # Due to a bug (?) the size of the root volume is misreported, resulting in a rebuild of the pool on every apply
    ]
  }
}

resource "scaleway_k8s_acl" "this" {
  cluster_id = scaleway_k8s_cluster.this.id

  dynamic "acl_rules" {
    for_each = toset(var.allowed_ip_ranges)
    content {
      ip          = acl_rules.value
      description = "Allow ${acl_rules.value}"
    }
  }

  acl_rules {
    scaleway_ranges = true
    description     = "Allow all Scaleway ranges"
  }
}
