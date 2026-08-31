output "resource_group_name" {
  description = "Resource group containing the VS Code dev host resources."
  value       = azurerm_resource_group.dev.name
}

output "vm_name" {
  description = "VM name."
  value       = module.vscode_dev_host.name
}

output "vm_resource_id" {
  description = "Azure resource ID of the VM."
  value       = module.vscode_dev_host.resource_id
}

output "public_ip_address" {
  description = "Primary public IP for SSH access."
  value       = try(module.vscode_dev_host.virtual_machine_azurerm.public_ip_address, null)
}

output "ssh_command" {
  description = "Convenience SSH command for VS Code Remote SSH."
  value       = "ssh ${var.admin_username}@${try(module.vscode_dev_host.virtual_machine_azurerm.public_ip_address, "<unknown>")}"
}

output "update_ssh_config" {
  description = "Reminder to update your SSH config with the new public IP."
  value       = "Update your SSH config C:\\Users\\sjoer\\.ssh\\config with the new public IP: ${try(module.vscode_dev_host.virtual_machine_azurerm.public_ip_address, "<unknown>")}"
}
