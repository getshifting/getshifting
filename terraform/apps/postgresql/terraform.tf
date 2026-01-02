terraform {
  required_version = ">= 0.14.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.51.0"
    }
  }
}

provider "azurerm" {
  subscription_id                 = var.env_subscription_id
  resource_provider_registrations = "none"
  features {
    virtual_machine {
      skip_shutdown_and_force_delete = true
      delete_os_disk_on_deletion     = true
    }
  }
}
