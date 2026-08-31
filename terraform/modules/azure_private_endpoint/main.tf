resource "azurerm_private_endpoint" "private_endpoint" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.subnet_id
  tags                          = var.tags
  custom_network_interface_name = "nic-${var.name}"

  private_service_connection {
    name                           = "${var.name}-serviceconnection"
    private_connection_resource_id = var.private_connection_resource_id
    is_manual_connection           = var.is_manual_connection
    subresource_names              = try([var.subresource_name], null)
    request_message                = try(var.request_message, null)
  }

  private_dns_zone_group {
    name                 = var.private_dns_zone_group_name
    private_dns_zone_ids = var.private_dns_zone_group_ids
  }

  dynamic "ip_configuration" {
    for_each = { for i, ip_config in var.ip_configurations : ip_config.private_ip_address => { index = i, member_name = ip_config.member_name } }

    content {
      name               = "${var.name}-ipconfig-${ip_configuration.value.index}"
      private_ip_address = ip_configuration.key
      subresource_name   = var.subresource_name
      member_name        = ip_configuration.value.member_name
    }
  }

  lifecycle {
    ignore_changes = [
    ]
  }
}