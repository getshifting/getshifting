module "keyvault" {
  source              = "Azure/avm-res-keyvault-vault/azurerm"
  location            = "westeurope"
  name                = "kv-euw-shift-prd"
  resource_group_name = module.avm-resource-group-aks.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  enable_telemetry    = false
  network_acls = {
    bypass   = "None"
    ip_rules = concat(var.allowed_cidrs, [data.azurerm_public_ip.aks_outbound.ip_address])
  }
  public_network_access_enabled = true
  role_assignments = {
    "service-principal-kv-admin" = {
      principal_id               = data.azurerm_client_config.current.object_id
      role_definition_id_or_name = "Key Vault Administrator"
    }
    "sec-aksadmins-secrets" = {
      principal_id               = var.aks_admins
      role_definition_id_or_name = "Key Vault Secrets Officer"
    }
    "sec-aksadmins-certs" = {
      principal_id               = var.aks_admins
      role_definition_id_or_name = "Key Vault Certificates Officer"
    }
  }
  secrets = {
    ssl_private_key = {
      name = "wildcard-ssl-key"
    }
    ssl_certificate = {
      name = "wildcard-ssl-crt"
    }
  }
  secrets_value = {
    ssl_private_key = tls_private_key.gateway_cert.private_key_pem
    ssl_certificate = tls_self_signed_cert.wildcard.cert_pem
  }
  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }
}
