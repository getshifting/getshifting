/*
This is a standalone terraform deployment for Azure SQL.

Standalone deployments use a single file without modules, and as little as possible variables.

Resources:
- https://learn.microsoft.com/en-us/azure/azure-sql/database/?view=azuresql
- Quickstart: https://learn.microsoft.com/en-us/azure/azure-sql/database/single-database-create-terraform-quickstart?view=azuresql&tabs=azure-cli
- Terraform Registry azurerm_mssql_server: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server

Commands:
# List the available editions in a location
az sql db list-editions --location westeurope -o table

*/

#    $$$$$$$$\ $$$$$$$$\ $$$$$$$\  $$$$$$$\   $$$$$$\  $$$$$$$$\  $$$$$$\  $$$$$$$\  $$\      $$\
#    \__$$  __|$$  _____|$$  __$$\ $$  __$$\ $$  __$$\ $$  _____|$$  __$$\ $$  __$$\ $$$\    $$$ |
#       $$ |   $$ |      $$ |  $$ |$$ |  $$ |$$ /  $$ |$$ |      $$ /  $$ |$$ |  $$ |$$$$\  $$$$ |
#       $$ |   $$$$$\    $$$$$$$  |$$$$$$$  |$$$$$$$$ |$$$$$\    $$ |  $$ |$$$$$$$  |$$\$$\$$ $$ |
#       $$ |   $$  __|   $$  __$$< $$  __$$< $$  __$$ |$$  __|   $$ |  $$ |$$  __$$< $$ \$$$  $$ |
#       $$ |   $$ |      $$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |      $$ |  $$ |$$ |  $$ |$$ |\$  /$$ |
#       $$ |   $$$$$$$$\ $$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |       $$$$$$  |$$ |  $$ |$$ | \_/ $$ |
#       \__|   \________|\__|  \__|\__|  \__|\__|  \__|\__|       \______/ \__|  \__|\__|     \__|
#
#
#

terraform {
  required_version = ">= 0.14.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.61.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }

}

provider "azurerm" {
  subscription_id                 = "30b3c71d-a123-a123-a123-abcd12345678"
  resource_provider_registrations = "none"
  features {}
}

#    $$$$$$$\   $$$$$$\
#    $$  __$$\ $$  __$$\
#    $$ |  $$ |$$ /  \__|
#    $$$$$$$  |$$ |$$$$\
#    $$  __$$< $$ |\_$$ |
#    $$ |  $$ |$$ |  $$ |
#    $$ |  $$ |\$$$$$$  |
#    \__|  \__| \______/
#
#
#

resource "azurerm_resource_group" "rg" {
  name     = "rg-euw-shift-prd-asql"
  location = "westeurope"
}

#    $$\   $$\ $$$$$$$$\ $$$$$$$$\ $$\      $$\  $$$$$$\  $$$$$$$\  $$\   $$\
#    $$$\  $$ |$$  _____|\__$$  __|$$ | $\  $$ |$$  __$$\ $$  __$$\ $$ | $$  |
#    $$$$\ $$ |$$ |         $$ |   $$ |$$$\ $$ |$$ /  $$ |$$ |  $$ |$$ |$$  /
#    $$ $$\$$ |$$$$$\       $$ |   $$ $$ $$\$$ |$$ |  $$ |$$$$$$$  |$$$$$  /
#    $$ \$$$$ |$$  __|      $$ |   $$$$  _$$$$ |$$ |  $$ |$$  __$$< $$  $$<
#    $$ |\$$$ |$$ |         $$ |   $$$  / \$$$ |$$ |  $$ |$$ |  $$ |$$ |\$$\
#    $$ | \$$ |$$$$$$$$\    $$ |   $$  /   \$$ | $$$$$$  |$$ |  $$ |$$ | \$$\
#    \__|  \__|\________|   \__|   \__/     \__| \______/ \__|  \__|\__|  \__|
#
#
#

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-euw-shift-prd"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.69.0.0/16"]
}

# Subnet for private endpoint
resource "azurerm_subnet" "subnet_pep" {
  name                 = "snet-euw-shift-prd-pep"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.69.1.0/24"]
}

#     $$$$$$\   $$$$$$\  $$\              $$$$$$\  $$$$$$$$\ $$$$$$$\  $$\    $$\ $$$$$$$$\ $$$$$$$\
#    $$  __$$\ $$  __$$\ $$ |            $$  __$$\ $$  _____|$$  __$$\ $$ |   $$ |$$  _____|$$  __$$\
#    $$ /  \__|$$ /  $$ |$$ |            $$ /  \__|$$ |      $$ |  $$ |$$ |   $$ |$$ |      $$ |  $$ |
#    \$$$$$$\  $$ |  $$ |$$ |            \$$$$$$\  $$$$$\    $$$$$$$  |\$$\  $$  |$$$$$\    $$$$$$$  |
#     \____$$\ $$ |  $$ |$$ |             \____$$\ $$  __|   $$  __$$<  \$$\$$  / $$  __|   $$  __$$<
#    $$\   $$ |$$ $$\$$ |$$ |            $$\   $$ |$$ |      $$ |  $$ |  \$$$  /  $$ |      $$ |  $$ |
#    \$$$$$$  |\$$$$$$ / $$$$$$$$\       \$$$$$$  |$$$$$$$$\ $$ |  $$ |   \$  /   $$$$$$$$\ $$ |  $$ |
#     \______/  \___$$$\ \________|       \______/ \________|\__|  \__|    \_/    \________|\__|  \__|
#                   \___|
#
#

resource "random_password" "azuresql_server_admin_password" {
  length           = 10
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


resource "azurerm_mssql_server" "server" {
  name                          = "sql-euw-vtx-shift-prd"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  administrator_login           = "SqlAdmin"
  administrator_login_password  = random_password.azuresql_server_admin_password.result
  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
}

#     $$$$$$\   $$$$$$\  $$\             $$$$$$$\  $$$$$$$\
#    $$  __$$\ $$  __$$\ $$ |            $$  __$$\ $$  __$$\
#    $$ /  \__|$$ /  $$ |$$ |            $$ |  $$ |$$ |  $$ |
#    \$$$$$$\  $$ |  $$ |$$ |            $$ |  $$ |$$$$$$$\ |
#     \____$$\ $$ |  $$ |$$ |            $$ |  $$ |$$  __$$\
#    $$\   $$ |$$ $$\$$ |$$ |            $$ |  $$ |$$ |  $$ |
#    \$$$$$$  |\$$$$$$ / $$$$$$$$\       $$$$$$$  |$$$$$$$  |
#     \______/  \___$$$\ \________|      \_______/ \_______/
#                   \___|
#
#

resource "azurerm_mssql_database" "db" {
  name                                = "GC_VTX_DB"
  server_id                           = azurerm_mssql_server.server.id
  collation                           = "SQL_Latin1_General_CP1_CI_AS"
  license_type                        = "LicenseIncluded"
  sku_name                            = "HS_MOPRMS_2" # Hyperscale, Memory Optimized, 2 vCores
  geo_backup_enabled                  = false
  storage_account_type                = "Local"
  transparent_data_encryption_enabled = true
  maintenance_configuration_name      = "SQL_Default"

  lifecycle {
    prevent_destroy = false
  }
}

#    $$$$$$$\  $$\   $$\  $$$$$$\
#    $$  __$$\ $$$\  $$ |$$  __$$\
#    $$ |  $$ |$$$$\ $$ |$$ /  \__|
#    $$ |  $$ |$$ $$\$$ |\$$$$$$\
#    $$ |  $$ |$$ \$$$$ | \____$$\
#    $$ |  $$ |$$ |\$$$ |$$\   $$ |
#    $$$$$$$  |$$ | \$$ |\$$$$$$  |
#    \_______/ \__|  \__| \______/
#
#
#

resource "azurerm_private_dns_zone" "pdnszone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

#    $$$$$$$\  $$$$$$$$\ $$$$$$$\
#    $$  __$$\ $$  _____|$$  __$$\
#    $$ |  $$ |$$ |      $$ |  $$ |
#    $$$$$$$  |$$$$$\    $$$$$$$  |
#    $$  ____/ $$  __|   $$  ____/
#    $$ |      $$ |      $$ |
#    $$ |      $$$$$$$$\ $$ |
#    \__|      \________|\__|
#
#
#

variable "ip_configurations" {
  type = list(any)
  default = [
    {
      private_ip_address = "10.69.1.101"
      member_name        = null
    }
  ]
}

resource "azurerm_private_endpoint" "private_endpoint" {
  name                          = "pep-${lower(azurerm_mssql_server.server.name)}"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  subnet_id                     = azurerm_subnet.subnet_pep.id
  custom_network_interface_name = "nic-pep-${lower(azurerm_mssql_server.server.name)}"

  private_service_connection {
    name                           = "pep-${lower(azurerm_mssql_server.server.name)}-serviceconnection"
    private_connection_resource_id = azurerm_mssql_server.server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "AzureSqlPrivateDnsZoneGroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.pdnszone.id]
  }

  dynamic "ip_configuration" {
    for_each = { for i, ip_config in var.ip_configurations : ip_config.private_ip_address => { index = i, member_name = ip_config.member_name } }

    content {
      name               = "${lower(azurerm_mssql_server.server.name)}-ipconfig-${ip_configuration.value.index}"
      private_ip_address = ip_configuration.key
      subresource_name   = "sqlServer"
      member_name        = ip_configuration.value.member_name
    }
  }

  lifecycle {
    ignore_changes = []
  }
}
