resource "azurerm_postgresql_flexible_server" "postgresql_flexible_server" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  tags                          = var.tags
  version                       = var.postgresql_flexible_server_version
  administrator_login           = var.administrator_login
  administrator_password        = var.administrator_password
  sku_name                      = var.sku_name
  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = var.geo_redundant_backup_enabled
  storage_mb                    = var.storage_mb
  storage_tier                  = var.storage_tier
  public_network_access_enabled = var.public_network_access_enabled
  zone                          = var.zone
  high_availability {
    mode                      = var.high_availability_mode
    standby_availability_zone = var.standby_availability_zone
  }
}
