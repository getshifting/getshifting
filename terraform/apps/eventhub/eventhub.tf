// Use Azure Verified Module for the resource group:
//   https://registry.terraform.io/modules/Azure/avm-res-resources-resourcegroup/azurerm/latest
module "avm-res-resources-resourcegroup" {
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  name             = var.resource_group_name
  location         = var.location
  tags             = var.tags
  enable_telemetry = false
}

// Eventhub and EventGrid
module "eventhub" {
  count                                          = var.deploy_eventhub == true ? 1 : 0
  source                                         = "../../modules/azure_eventhub"
  subscription_id                                = var.env_subscription_id
  resource_group_name                            = module.avm-res-resources-resourcegroup.name
  location                                       = var.location
  tags                                           = merge(var.tags, var.eventhub_tags)
  eventhub_namespace_name                        = var.eventhub_namespace_name
  eventhub_storage_account_id                    = module.avm-res-storage-storageaccount[0].resource_id
  eventgrid_system_topic_name                    = var.eventgrid_system_topic_name
  eventgrid_system_topic_event_subscription_name = var.eventgrid_system_topic_event_subscription_name
  eventhub_name                                  = var.eventhub_name
}

// Eventgrid Source: Storage Account
// Use Azure Verified Module for the storage account:
//   https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest
module "avm-res-storage-storageaccount" {
  count                         = var.deploy_eventhub == true ? 1 : 0
  source                        = "Azure/avm-res-storage-storageaccount/azurerm"
  location                      = var.location
  name                          = var.eventhub_storage_account_name
  resource_group_name           = module.avm-res-resources-resourcegroup.name
  account_kind                  = "StorageV2"
  account_replication_type      = "LRS"
  account_tier                  = "Standard"
  https_traffic_only_enabled    = true
  local_user_enabled            = false
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = true
  shared_access_key_enabled     = true
  tags                          = merge(var.tags, var.eventhub_tags)
  enable_telemetry              = false
}

// Use Azure Verified Module for the network:
//   https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest
module "avm-res-network-virtualnetwork" {
  count         = var.deploy_eventhub_pep == true ? 1 : 0
  source        = "Azure/avm-res-network-virtualnetwork/azurerm"
  address_space = ["10.69.0.0/16"]
  location      = var.location
  name          = var.vnet_name
  parent_id     = module.avm-res-resources-resourcegroup.resource_id
  tags          = var.tags
  subnets = {
    "subnet-pep" = {
      name             = var.subnet_name
      address_prefixes = ["10.69.1.0/24"]
    }
  }
  enable_telemetry = false
}

// Private DNS Zone
// Use Azure Verified Module for the private dns zone:
//   https://registry.terraform.io/modules/Azure/avm-res-network-privatednszone/azurerm/latest
module "avm-res-network-privatednszone_eventhub" {
  count            = var.deploy_eventhub_pep == true ? 1 : 0
  source           = "Azure/avm-res-network-privatednszone/azurerm"
  domain_name      = var.privatezone_eventhub
  parent_id        = module.avm-res-resources-resourcegroup.resource_id
  tags             = var.tags
  enable_telemetry = false
}
module "avm-res-network-privatednszone_blob" {
  count            = var.deploy_eventhub_pep == true ? 1 : 0
  source           = "Azure/avm-res-network-privatednszone/azurerm"
  domain_name      = var.privatezone_blob
  parent_id        = module.avm-res-resources-resourcegroup.resource_id
  tags             = var.tags
  enable_telemetry = false
}

// Private DNS Zone Virtual Network Link
module "eventhub_private_dns_zone_vnet_link_eventhub" {
  count                 = var.deploy_eventhub_pep == true ? 1 : 0
  source                = "../../modules/azure_private_dns_zone_virtual_network_link"
  name                  = "dpl-${lower(var.vnet_name)}"
  private_dns_zone_name = var.privatezone_eventhub
  virtual_network_id    = module.avm-res-network-virtualnetwork[0].resource_id
  resource_group_name   = var.resource_group_name
  depends_on            = [module.avm-res-network-privatednszone_eventhub]
}
module "eventhub_private_dns_zone_vnet_link_blob" {
  count                 = var.deploy_eventhub_pep == true ? 1 : 0
  source                = "../../modules/azure_private_dns_zone_virtual_network_link"
  name                  = "dpl-${lower(var.vnet_name)}"
  private_dns_zone_name = var.privatezone_blob
  virtual_network_id    = module.avm-res-network-virtualnetwork[0].resource_id
  resource_group_name   = var.resource_group_name
  depends_on            = [module.avm-res-network-privatednszone_blob]
}

// Eventhub Private Endpoint
module "eventhub_private_endpoint" {
  count                          = var.deploy_eventhub_pep == true ? 1 : 0
  source                         = "../../modules/azure_private_endpoint"
  name                           = "pep-${module.eventhub[0].eventhub_namespace.name}"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = module.avm-res-network-virtualnetwork[0].subnets["subnet-pep"].resource_id
  tags                           = var.tags
  private_connection_resource_id = module.eventhub[0].eventhub_namespace.id
  is_manual_connection           = false
  subresource_name               = "namespace"
  private_dns_zone_group_name    = "EventHubPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.avm-res-network-privatednszone_eventhub[0].resource_id]
  ip_configurations              = var.eventhub_private_endpoint_ip_configurations
}
// Storage Account Private Endpoint
module "storage_account_private_endpoint" {
  count                          = var.deploy_eventhub_pep == true ? 1 : 0
  source                         = "../../modules/azure_private_endpoint"
  name                           = "pep-${module.avm-res-storage-storageaccount[0].name}"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = module.avm-res-network-virtualnetwork[0].subnets["subnet-pep"].resource_id
  tags                           = var.tags
  private_connection_resource_id = module.avm-res-storage-storageaccount[0].resource_id
  is_manual_connection           = false
  subresource_name               = "blob"
  private_dns_zone_group_name    = "BlobPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.avm-res-network-privatednszone_blob[0].resource_id]
  ip_configurations              = var.storageaccount_private_endpoint_ip_configurations
}

// Log analytics workspace
module "law" {
  count                      = var.deploy_eventhub_logs == true ? 1 : 0
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
module "eventhub_diagnostic_setting" {
  count                      = var.deploy_eventhub_logs == true ? 1 : 0
  source                     = "../../modules/azure_diagnostic_setting"
  log_analytics_workspace_id = module.law[0].id
  targets_resource_id = [
    module.eventhub[0].eventhub_namespace.id,
    module.eventhub[0].eventgrid_system_topic.id
  ]
}
