resource "azurerm_eventhub_namespace" "namespace" {
  name                          = var.eventhub_namespace_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = "Standard"
  capacity                      = var.eventhub_namespace_capacity
  public_network_access_enabled = true
  tags                          = var.tags

  # The list of IP addresses is derived from https://www.microsoft.com/en-nz/download/details.aspx?id=56519 - AzureEventGrid.WestEurope
  network_rulesets {
    default_action                 = "Deny"
    public_network_access_enabled  = true
    trusted_service_access_enabled = true
    ip_rule {
      ip_mask = "4.210.129.0/24"
      action  = "Allow"
    }
    ip_rule {
      ip_mask = "40.74.31.128/25"
      action  = "Allow"
    }
    ip_rule {
      ip_mask = "40.114.160.176/28"
      action  = "Allow"
    }
    ip_rule {
      ip_mask = "40.114.160.192/28"
      action  = "Allow"
    }
    ip_rule {
      ip_mask = "40.114.169.0/28"
      action  = "Allow"
    }
    ip_rule {
      ip_mask = "51.137.16.224/28"
      action  = "Allow"
    }
    ip_rule {
      ip_mask = "2603:1020:206:1::380/121"
      action  = "Allow"
    }

  }
}

resource "azurerm_eventgrid_system_topic" "eventgrid_system_topic" {
  name                = var.eventgrid_system_topic_name
  location            = var.location
  resource_group_name = var.resource_group_name
  source_resource_id  = var.eventhub_storage_account_id
  tags                = var.tags
  topic_type          = "Microsoft.Storage.StorageAccounts"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "eventgrid_system_topic_event_subscription" {
  name                                 = var.eventgrid_system_topic_event_subscription_name
  advanced_filtering_on_arrays_enabled = true
  event_delivery_schema                = "EventGridSchema"
  eventhub_endpoint_id                 = azurerm_eventhub.eventhub.id
  included_event_types                 = ["Microsoft.Storage.BlobCreated", "Microsoft.Storage.BlobRenamed"]
  resource_group_name                  = var.resource_group_name
  system_topic                         = azurerm_eventgrid_system_topic.eventgrid_system_topic.name
  retry_policy {
    event_time_to_live    = 1440
    max_delivery_attempts = 30
  }
  depends_on = [
    azurerm_eventgrid_system_topic.eventgrid_system_topic,
  ]
}

resource "azurerm_eventhub" "eventhub" {
  name            = var.eventhub_name
  namespace_id    = azurerm_eventhub_namespace.namespace.id
  partition_count = 1
  status          = "Active"
  retention_description {
    cleanup_policy          = "Delete"
    retention_time_in_hours = 1
  }
}
