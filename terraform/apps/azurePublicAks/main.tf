/*
This is a terraform deployment for public AKS with pre-configured gateway api for ingress.

In this deployment I use Azure Verified Modules as much as possible, and as little as possible variables.
  Variables are only used to accomodate for overrides in the override.tf file.

Resources:
- Wiki: https://wiki.getshifting.com/aksgatewayapi
- https://learn.microsoft.com/en-us/azure/aks/
- Quickstart: https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-terraform?pivots=development-environment-azure-cli
- Terraform Registry azurerm_kubernetes_cluster: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster

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
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.81.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~>2.9"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.3.0"
    }
  }
}

provider "azurerm" {
  subscription_id                 = "30b3c71d-a123-a123-a123-abcd12345678"
  tenant_id                       = "7e4an71d-a123-a123-a123-abcd12345678"
  resource_provider_registrations = "none"
  features {}
}

data "azurerm_client_config" "current" {}

# Setup kubernetes provider to use the AKS cluster's admin kubeconfig for authentication
locals {
  # Decode admin kubeconfig exported by the AKS AVM module so the provider can authenticate.
  aks_admin_kubeconfig = yamldecode(module.aks_public_cluster.kube_admin_config)
}
provider "kubernetes" {
  host                   = local.aks_admin_kubeconfig.clusters[0].cluster.server
  client_certificate     = base64decode(local.aks_admin_kubeconfig.users[0].user["client-certificate-data"])
  client_key             = base64decode(local.aks_admin_kubeconfig.users[0].user["client-key-data"])
  cluster_ca_certificate = base64decode(local.aks_admin_kubeconfig.clusters[0].cluster["certificate-authority-data"])
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

module "avm-resource-group-aks" {
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  name             = "rg-euw-shift-prd-aks"
  location         = "westeurope"
  enable_telemetry = false
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

output "next_step_enable_k8s_manifests" {
  description = "Command to run for deploying Kubernetes manifests after infrastructure is ready"
  value       = var.deploy_k8s_resources ? null : "terraform apply -var=deploy_k8s_resources=true -auto-approve"
}

output "next_step_update_hosts_file" {
  description = "Command to run for updating the hosts file after everything is ready"
  value       = var.deploy_k8s_resources ? "Open C:/Windows/System32/drivers/etc/hosts as an administrator; Add ${data.kubernetes_resource.gateway[0].object.status.addresses[0].value} ${var.fqdn}" : null
}
