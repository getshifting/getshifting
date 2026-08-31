terraform {
  required_version = ">= 1.10"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.2, < 4.0.0"
    }
  }
}

provider "azurerm" {
  subscription_id                 = var.subscription_id != "" ? var.subscription_id : null
  resource_provider_registrations = "none"

  features {
    virtual_machine {
      skip_shutdown_and_force_delete = true
      delete_os_disk_on_deletion     = true
    }
  }
}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

locals {
  base_name   = lower("${var.project}-${var.environment}-${random_string.suffix.result}")
  vm_name     = substr("vm-${local.base_name}", 0, 63)
  vnet_name   = substr("vnet-${local.base_name}", 0, 64)
  subnet_name = substr("snet-${local.base_name}", 0, 64)
  nsg_name    = substr("nsg-${local.base_name}", 0, 80)

  tags = merge(
    {
      app         = "vscode-remote-dev"
      environment = var.environment
      managedBy   = "terraform"
      purpose     = "devcontainer-host"
    },
    var.tags
  )

  custom_data = base64encode(
    templatefile("${path.module}/cloud-init.yaml", {
      admin_username = var.admin_username
    })
  )
}

resource "azurerm_resource_group" "dev" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "dev" {
  name                = local.vnet_name
  resource_group_name = azurerm_resource_group.dev.name
  location            = azurerm_resource_group.dev.location
  address_space       = [var.vnet_cidr]
  tags                = local.tags
}

resource "azurerm_subnet" "dev" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.dev.name
  virtual_network_name = azurerm_virtual_network.dev.name
  address_prefixes     = [var.subnet_cidr]
}

resource "azurerm_network_security_group" "dev" {
  name                = local.nsg_name
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.allowed_ssh_cidrs
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.dev.name
  network_security_group_name = azurerm_network_security_group.dev.name
}

resource "azurerm_subnet_network_security_group_association" "dev" {
  subnet_id                 = azurerm_subnet.dev.id
  network_security_group_id = azurerm_network_security_group.dev.id
}

module "vscode_dev_host" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.21.0"

  enable_telemetry    = false
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.dev.name
  location            = azurerm_resource_group.dev.location
  zone                = var.vm_zone

  os_type  = "Linux"
  sku_size = var.vm_size

  source_image_reference = {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  encryption_at_host_enabled = false

  account_credentials = {
    password_authentication_disabled = true
    admin_credentials = {
      username                           = var.admin_username
      ssh_keys                           = [var.admin_ssh_public_key]
      generate_admin_password_or_ssh_key = false
    }
  }

  network_interfaces = {
    nic_primary = {
      name = "${local.vm_name}-nic"
      ip_configurations = {
        ipconfig_primary = {
          name                          = "${local.vm_name}-ipcfg"
          private_ip_subnet_resource_id = azurerm_subnet.dev.id
          create_public_ip_address      = true
          public_ip_address_name        = "${local.vm_name}-pip"
        }
      }
      network_security_groups = {
        nsg_primary = {
          network_security_group_resource_id = azurerm_network_security_group.dev.id
        }
      }
      accelerated_networking_enabled = var.enable_accelerated_networking
    }
  }

  public_ip_configuration_details = {
    allocation_method = "Static"
    sku               = "Standard"
    sku_tier          = "Regional"
    ip_version        = "IPv4"
  }

  custom_data = local.custom_data

  managed_identities = {
    system_assigned = true
  }

  priority        = "Spot"
  eviction_policy = "Deallocate"
  max_bid_price   = var.max_bid_price_usd

  termination_notification = {
    enabled = true
    timeout = "PT5M"
  }

  patch_mode            = "AutomaticByPlatform"
  patch_assessment_mode = "AutomaticByPlatform"
  boot_diagnostics      = true

  shutdown_schedules = {
    daily = {
      daily_recurrence_time = var.auto_shutdown_local_hhmm
      timezone              = var.shutdown_timezone
      enabled               = var.enable_auto_shutdown
      notification_settings = {
        enabled = false
      }
    }
  }

  tags = local.tags

  depends_on = [azurerm_subnet_network_security_group_association.dev]
}
