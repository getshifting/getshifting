output "name" {
  description = "The name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.law.name
}

output "id" {
  description = "The ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.law.id
}

output "resource_group" {
  description = "The resource group of the Log Analytics Workspace"
  value       = var.resource_group_name
}