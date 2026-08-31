module "public_gateway" {
  source = "../../modules/scw_public_gateway"
  name   = "pgw-ams"
  type   = "VPC-GW-S"
  zone   = var.zone
  private_network_attachments = {
    pgw = {
      private_network_id = module.private_network_pgw.id
      push_default_route = true
    }
    k8s = {
      private_network_id = module.private_network_k8s.id
      push_default_route = true
    }
  }
  ssh_key_id        = scaleway_iam_ssh_key.sjoerd.id
  allowed_ip_ranges = [var.my_ip_address]
}
