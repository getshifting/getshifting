# Subscription, region and resource groups
env_subscription_id = "30b3c71d-a123-a123-a123-abcd12345678"
resource_group_name = "rg-euw-shift-prd-eventhub"
location            = "westeurope"

# Default tags
tags = {
  company     = "GetShifting",
  domain      = "IT",
  team        = "DevOps",
  environment = "Production"
}

# EventHub Resources
deploy_eventhub         = true
eventhub_name           = "evh-euw-shift-prd-001"
eventhub_namespace_name = "evhns-euw-shift-prd-001"
eventhub_namespace_private_endpoint_ip_configurations = [
  {
    private_ip_address = "10.69.1.11"
    member_name        = null
  }
]
eventgrid_system_topic_name                    = "egst-euw-shift-prd-blob"
eventgrid_system_topic_event_subscription_name = "evgs-euw-shift-prd-blobCreateUpdate"
eventhub_storage_account_name                  = "steuwshiftprdblob"
eventhub_tags = {
  project = "GetShifting"
  app     = "EventHub"
  owner   = "DevOpsTeam"
}

# Variables for Private Endpoint
deploy_eventhub_pep  = true
vnet_name            = "vnet-euw-shift-prd"
subnet_name          = "snet-euw-shift-prd-pep"
privatezone_eventhub = "privatelink.servicebus.windows.net"
privatezone_blob     = "privatelink.blob.core.windows.net"

# Variables for Log Analytics Workspace
deploy_eventhub_logs = true
law_name             = "law-euw-shift-prd-eventhub"
