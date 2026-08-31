#     $$$$$$\  $$\   $$\  $$$$$$\
#    $$  __$$\ $$ | $$  |$$  __$$\
#    $$ /  $$ |$$ |$$  / $$ /  \__|
#    $$$$$$$$ |$$$$$  /  \$$$$$$\
#    $$  __$$ |$$  $$<    \____$$\
#    $$ |  $$ |$$ |\$$\  $$\   $$ |
#    $$ |  $$ |$$ | \$$\ \$$$$$$  |
#    \__|  \__|\__|  \__| \______/
#
#
#

# User assigned identity for AKS
module "aks_identity" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "0.4.0" # Version 0.5.0 (latest) has a bug: https://github.com/Azure/terraform-azurerm-avm-res-managedidentity-userassignedidentity/issues/109
  location            = "westeurope"
  name                = "id-euw-shift-prd-aks"
  resource_group_name = module.avm-resource-group-aks.name
  enable_telemetry    = false
}

# Workload identity general
module "aks_workload_identity" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "0.4.0" # Version 0.5.0 (latest) has a bug: https://github.com/Azure/terraform-azurerm-avm-res-managedidentity-userassignedidentity/issues/109
  location            = "westeurope"
  name                = "id-euw-shift-prd-aks-workload"
  resource_group_name = module.avm-resource-group-aks.name
  enable_telemetry    = false
  role_assignments = {
    secrets_user = {
      role_definition_id_or_name = "Key Vault Secrets User"
      scope                      = module.keyvault.resource_id
      description                = "Key Vault Secrets User access to read secrets"
    }
  }
  # Maximum number of federated credentials per identity is 20.
  federated_identity_credentials = {
    aks_workload_identity_gateway = {
      name        = "fc-euw-shift-prd-aks-gateway-httpbin"
      issuer      = module.aks_public_cluster.oidc_issuer_profile_issuer_url
      subject     = "system:serviceaccount:ops:httpbin"
      description = "Federated identity credential for Gateway API"
      audience    = ["api://AzureADTokenExchange"]
    }
  }
  depends_on = [
    module.aks_public_cluster
  ]
}

# AKS Public Cluster
module "aks_public_cluster" {
  source = "Azure/avm-res-containerservice-managedcluster/azurerm"

  location  = "westeurope"
  name      = "aks-euw-shift-prd"
  parent_id = module.avm-resource-group-aks.resource_id

  aad_profile = {
    enable_azure_rbac      = false
    tenant_id              = data.azurerm_client_config.current.tenant_id
    admin_group_object_ids = [var.aks_admins]
    managed                = true
  }
  addon_profile_key_vault_secrets_provider = {
    enabled = true
    config = {
      enable_secret_rotation = true
    }
  }
  agent_pools = {
    npuser = {
      name                = "npuser"
      vm_size             = "Standard_E2s_v6"
      mode                = "User"
      type                = "VirtualMachineScaleSets"
      enable_auto_scaling = true
      max_count           = 2
      max_pods            = 30
      min_count           = 1
      os_disk_size_gb     = 128
      priority            = "Spot"
      eviction_policy     = "Delete"
      spot_max_price      = -1
      upgrade_settings = {
        max_surge = "10%"
      }
    }
  }
  agentpool_timeouts = {
    create = "20m"
    delete = "20m"
    read   = "5m"
    update = "20m"
  }
  api_server_access_profile = {
    disable_run_command    = true
    enable_private_cluster = false
    authorized_ip_ranges   = var.allowed_cidrs
  }
  default_agent_pool = {
    name                = "system"
    vm_size             = "Standard_D2S_v6"
    enable_auto_scaling = true
    max_count           = 2
    max_pods            = 30
    min_count           = 1
    node_taints         = ["CriticalAddonsOnly=true:NoSchedule"]
    upgrade_settings = {
      max_surge = "10%"
    }
  }
  # Local account access is used by the terraform kubernetes provider
  disable_local_accounts = false
  dns_prefix             = "shift-public-aks"
  enable_telemetry       = false
  ingress_profile = {
    gateway_api = {
      installation = "Standard"
    }
    web_app_routing = {
      enabled = true
      gateway_api_implementations = {
        app_routing_istio = {
          mode = "Enabled"
        }
      }
      nginx = {
        default_ingress_controller_type = "None"
      }
    }
  }
  # List the available editions in a location: az aks get-versions --location westeurope --output table
  kubernetes_version = "1.36.1"
  linux_profile = {
    admin_username = "azadmin"
    ssh = {
      public_keys = [
        {
          key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
        }
      ]
    }
  }
  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = [module.aks_identity.resource_id]
  }
  network_profile = {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    outbound_type       = "loadBalancer"
  }

  node_resource_group = "${module.avm-resource-group-aks.name}-nodes"
  oidc_issuer_profile = {
    enabled = true
  }
  security_profile = {
    workload_identity = {
      enabled = true
    }
  }
  sku = {
    name = "Base"
    tier = "Free"
  }

  depends_on = [
    module.aks_identity,
  ]
}

#    $$\   $$\ $$\   $$\ $$$$$$$\  $$$$$$$$\  $$$$$$\   $$$$$$\  $$\   $$\ $$$$$$$$\ $$$$$$\  $$$$$$\
#    $$ | $$  |$$ |  $$ |$$  __$$\ $$  _____|$$  __$$\ $$  __$$\ $$$\  $$ |$$  _____|\_$$  _|$$  __$$\
#    $$ |$$  / $$ |  $$ |$$ |  $$ |$$ |      $$ /  \__|$$ /  $$ |$$$$\ $$ |$$ |        $$ |  $$ /  \__|
#    $$$$$  /  $$ |  $$ |$$$$$$$\ |$$$$$\    $$ |      $$ |  $$ |$$ $$\$$ |$$$$$\      $$ |  $$ |$$$$\
#    $$  $$<   $$ |  $$ |$$  __$$\ $$  __|   $$ |      $$ |  $$ |$$ \$$$$ |$$  __|     $$ |  $$ |\_$$ |
#    $$ |\$$\  $$ |  $$ |$$ |  $$ |$$ |      $$ |  $$\ $$ |  $$ |$$ |\$$$ |$$ |        $$ |  $$ |  $$ |
#    $$ | \$$\ \$$$$$$  |$$$$$$$  |$$$$$$$$\ \$$$$$$  | $$$$$$  |$$ | \$$ |$$ |      $$$$$$\ \$$$$$$  |
#    \__|  \__| \______/ \_______/ \________| \______/  \______/ \__|  \__|\__|      \______| \______/
#
#
#

# Save the kubeconfig to a local file for use with kubectl
#  For manual use, run:
#  terraform output -raw kube_user_config | Set-Content -Path "$HOME\.kube\aks_public_user.yaml"

resource "local_file" "kube_user_config" {
  content  = module.aks_public_cluster.kube_config
  filename = var.kube_config_path
}

#     $$$$$$\  $$\   $$\ $$$$$$$$\ $$$$$$$\  $$\   $$\ $$$$$$$$\
#    $$  __$$\ $$ |  $$ |\__$$  __|$$  __$$\ $$ |  $$ |\__$$  __|
#    $$ /  $$ |$$ |  $$ |   $$ |   $$ |  $$ |$$ |  $$ |   $$ |
#    $$ |  $$ |$$ |  $$ |   $$ |   $$$$$$$  |$$ |  $$ |   $$ |
#    $$ |  $$ |$$ |  $$ |   $$ |   $$  ____/ $$ |  $$ |   $$ |
#    $$ |  $$ |$$ |  $$ |   $$ |   $$ |      $$ |  $$ |   $$ |
#     $$$$$$  |\$$$$$$  |   $$ |   $$ |      \$$$$$$  |   $$ |
#     \______/  \______/    \__|   \__|       \______/    \__|
#
#
#

locals {
  aks_outbound_ip_id = module.aks_public_cluster.network_profile_load_balancer_profile_effective_outbound_ips[0].id
}

data "azurerm_public_ip" "aks_outbound" {
  name                = basename(local.aks_outbound_ip_id)
  resource_group_name = split("/", local.aks_outbound_ip_id)[4]
}

output "aks_public_ip_address_outbound" {
  description = "Public IP address of the AKS cluster for outbound traffic."
  value       = data.azurerm_public_ip.aks_outbound.ip_address
}
