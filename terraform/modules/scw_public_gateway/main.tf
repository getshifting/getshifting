terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
}

# Use a local variable to compute a hash of my SSH key
locals {
  ssh_key_hash = sha256(join(",", [
    var.ssh_key_id
  ]))
}

# Create a fixed public IP address for the public gateway
resource "scaleway_vpc_public_gateway_ip" "this" {
  zone = var.zone
}

# Public gateway with a public IP address and a bastion host enabled
resource "scaleway_vpc_public_gateway" "this" {
  name = var.name
  type = var.type
  zone = var.zone

  # IP address for the public gateway
  ip_id = scaleway_vpc_public_gateway_ip.this.id

  # Bastion host configuration
  bastion_enabled   = true
  bastion_port      = 61000
  refresh_ssh_keys  = local.ssh_key_hash
  allowed_ip_ranges = var.allowed_ip_ranges
}

# Attach the public gateway to one or more private networks
resource "scaleway_vpc_gateway_network" "this" {
  for_each           = var.private_network_attachments
  gateway_id         = scaleway_vpc_public_gateway.this.id
  private_network_id = each.value.private_network_id
  enable_masquerade  = true
  ipam_config {
    push_default_route = each.value.push_default_route
  }
}
