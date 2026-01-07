// random password for the PostgreSql admin
resource "random_password" "postgresql_admin_password" {
  length           = 14
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

// Use Azure Verified Module for the resource group:
//   https://registry.terraform.io/modules/Azure/avm-res-resources-resourcegroup/azurerm/latest
module "avm-res-resources-resourcegroup" {
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  name             = var.resource_group_name
  location         = var.location
  tags             = var.tags
  enable_telemetry = false
}

// Flexible PostgreSql Server
module "postgresql_flexible_server" {
  source                             = "../../modules/azure_postgresql_flexible_server"
  name                               = var.postgresql_flexible_server_name
  resource_group_name                = var.resource_group_name
  location                           = var.location
  tags                               = merge(var.tags, var.postgresql_tags)
  postgresql_flexible_server_version = 16
  administrator_login                = "psqladmin"
  administrator_password             = random_password.postgresql_admin_password.result
  sku_name                           = "GP_Standard_D2s_v3"
  backup_retention_days              = 8
  geo_redundant_backup_enabled       = true
  zone                               = 1
  high_availability_mode             = "SameZone" # "ZoneRedundant" - Zoneredundant deploys are temporarily disabled in region West Europe, see readme.md in module
  standby_availability_zone          = 1
  storage_mb                         = 32768
  storage_tier                       = "P6"
  public_network_access_enabled      = false
}

// Use Azure Verified Module for the network:
//   https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest
module "avm-res-network-virtualnetwork" {
  count         = var.deploy_psql_pep == true ? 1 : 0
  source        = "Azure/avm-res-network-virtualnetwork/azurerm"
  address_space = ["10.69.0.0/16"]
  location      = var.location
  name          = var.vnet_name
  parent_id     = module.avm-res-resources-resourcegroup.resource_id
  tags          = var.tags
  subnets = {
    "subnet1" = {
      name             = var.subnet_name
      address_prefixes = ["10.69.1.0/24"]
    }
  }
  enable_telemetry = false
}

// Private DNS Zone
// Use Azure Verified Module for the private dns zone:
//   https://registry.terraform.io/modules/Azure/avm-res-network-privatednszone/azurerm/latest
module "avm-res-network-privatednszone" {
  count            = var.deploy_psql_pep == true ? 1 : 0
  source           = "Azure/avm-res-network-privatednszone/azurerm"
  domain_name      = var.privatezone
  parent_id        = module.avm-res-resources-resourcegroup.resource_id
  tags             = var.tags
  enable_telemetry = false
}

// Private DNS Zone Virtual Network Link
module "psql_private_dns_zone_vnet_link" {
  count                 = var.deploy_psql_pep == true ? 1 : 0
  source                = "../../modules/azure_private_dns_zone_virtual_network_link"
  name                  = "dpl-${lower(var.vnet_name)}"
  private_dns_zone_name = var.privatezone
  virtual_network_id    = module.avm-res-network-virtualnetwork[0].resource_id
  resource_group_name   = var.resource_group_name
  depends_on            = [module.avm-res-network-privatednszone]
}

// Flexible PostgreSQL Server Private Endpoint
module "postgresql_flexible_server_private_endpoint" {
  count                          = var.deploy_psql_pep == true ? 1 : 0
  source                         = "../../modules/azure_private_endpoint"
  name                           = "pep-${module.postgresql_flexible_server.name}"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = module.avm-res-network-virtualnetwork[0].subnets["subnet1"].resource_id
  tags                           = var.tags
  private_connection_resource_id = module.postgresql_flexible_server.id
  is_manual_connection           = false
  subresource_name               = "postgresqlServer"
  private_dns_zone_group_name    = "PostgresqlPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.avm-res-network-privatednszone[0].resource_id]
  ip_configurations              = var.postgresql_flexible_server_private_endpoint_ip_configurations
}

// Log analytics workspace
module "law" {
  count                      = var.deploy_psql_logs == true ? 1 : 0
  source                     = "../../modules/azure_log_analytics_workspace"
  name                       = var.law_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  sku                        = "PerGB2018"
  retention_in_days          = 30
  daily_quota_gb             = 2
  internet_ingestion_enabled = true
  internet_query_enabled     = true
  tags                       = var.tags
}

// Diagnostic settings
module "psql_diagnostic_setting" {
  count                      = var.deploy_psql_logs == true ? 1 : 0
  source                     = "../../modules/azure_diagnostic_setting"
  log_analytics_workspace_id = module.law[0].id
  targets_resource_id = [
    module.postgresql_flexible_server.id
  ]
}
