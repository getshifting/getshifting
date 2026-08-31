module "instance_jumpbox" {
  source             = "../../modules/scw_instance_server"
  project_id         = var.project_id
  zone               = var.zone
  name               = "vm-jumpbox"
  private_network_id = module.private_network_vms.id
  ip_address         = "10.10.2.2"
  type               = "BASIC3-X2C-4G"
  image              = "fedora_44"
  root_volume_size   = 10
}
