
# Subscription, region and resource groups
env_subscription_id = "30b3c71d-a123-a123-a123-abcd12345678"
resource_group_name = "rg-euw-shift-prd-tfpsql"
location            = "westeurope"

# Default tags
tags = {
  company     = "GetShifting",
  domain      = "IT",
  team        = "DevOps",
  environment = "Production"
}

# PostgreSQL Flexible Server
postgresql_flexible_server_name = "psql-euw-shift-prd"
postgresql_flexible_server_private_endpoint_ip_configurations = [
  {
    private_ip_address = "10.69.1.10"
    member_name        = null
  }
]
postgresql_tags = {
  project = "GetShifting"
  app     = "PostgreSQL"
  owner   = "DevOpsTeam"
}

# Variables for Private Endpoint
deploy_psql_pep = true
vnet_name       = "vnet-euw-shift-prd"
subnet_name     = "snet-euw-shift-prd-pep"
privatezone     = "privatelink.postgres.database.azure.com"

# Variables for Log Analytics Workspace
deploy_psql_logs = true
law_name         = "law-euw-shift-prd-tfpsql"
