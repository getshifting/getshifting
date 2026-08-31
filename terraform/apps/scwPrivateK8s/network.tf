module "vpc" {
  source     = "../../modules/scw_vpc"
  name       = "vpc-ams"
  region     = var.region
  project_id = var.project_id
}

module "private_network_pgw" {
  source      = "../../modules/scw_private_network"
  name        = "pnet-pgw"
  vpc_id      = module.vpc.id
  region      = var.region
  ipv4_subnet = "10.10.1.0/24"
}

module "private_network_vms" {
  source      = "../../modules/scw_private_network"
  name        = "pnet-ams-vms"
  vpc_id      = module.vpc.id
  region      = var.region
  ipv4_subnet = "10.10.2.0/24"
}

module "private_network_k8s" {
  source      = "../../modules/scw_private_network"
  name        = "pnet-ams-k8s"
  vpc_id      = module.vpc.id
  region      = var.region
  ipv4_subnet = "10.10.16.0/20"
}
