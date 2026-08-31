# Eventhub namespace resource
output "eventhub_namespace" {
  value = azurerm_eventhub_namespace.namespace
}

# Eventgrid system topic resource
output "eventgrid_system_topic" {
  value = azurerm_eventgrid_system_topic.eventgrid_system_topic
}
