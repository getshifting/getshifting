resource "scaleway_registry_namespace" "this" {
  name      = "cr-ams"
  region    = var.region
  is_public = false
}
