output "name" {
  description = "Specifies the name of the PostgreSQL Flexible server."
  value       = azurerm_postgresql_flexible_server.postgresql_flexible_server.name
}

output "id" {
  description = "Specifies the resource id of the PostgreSQL Flexible server."
  value       = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
}