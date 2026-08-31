terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
}

resource "scaleway_vpc_private_network" "this" {
  name   = var.name
  vpc_id = var.vpc_id
  region = var.region
  ipv4_subnet {
    subnet = var.ipv4_subnet
  }
}
