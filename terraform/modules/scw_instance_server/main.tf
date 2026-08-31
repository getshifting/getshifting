terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
}

resource "scaleway_ipam_ip" "this" {
  address = var.ip_address
  source {
    private_network_id = var.private_network_id
  }
}

resource "scaleway_instance_server" "this" {
  project_id = var.project_id
  zone       = var.zone
  name       = var.name
  type       = var.type
  image      = var.image
  tags       = var.tags

  root_volume {
    size_in_gb = var.root_volume_size
  }
}

resource "scaleway_instance_private_nic" "this" {
  private_network_id = var.private_network_id
  server_id          = scaleway_instance_server.this.id
  ipam_ip_ids        = [scaleway_ipam_ip.this.id]
}
