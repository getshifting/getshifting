terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
}

resource "scaleway_vpc" "this" {
  name       = var.name
  region     = var.region
  project_id = var.project_id
  tags       = var.tags
}
