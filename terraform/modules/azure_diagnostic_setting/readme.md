# Diagnostic Settings

This module deploys diagnostic settings for a resource, enabling all available logs and metrics.

## Wiki and usage

For more information about this module, see [this wiki page](https://wiki.getshifting.com/terraformmodulediagnosticsettings).

This module is used by the [postgresql application](../../apps/postgresql.tf)

## Resources

[Diagnostic settings in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings)
[Terraform Registry azurerm_monitor_diagnostic_setting](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting)

## Using the module for a single resource

Use the module to set diagnostic settings for a single resource:

```terraform
module "diagnostic_settings" {
  source                     = "../modules/diagnostic_settings_all"
  log_analytics_workspace_id = var.law_id
  targets_resource_id = [
    azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  ]
}
```

## Using the module for multiple resources at once

You can use the module for multiple resources at once by providing a list of resource IDs, see here an example on setting diagnostic settings for multiple resources:

```terraform
module "sa_diag" {
  source                     = "../modules/diagnostic_settings_all"
  log_analytics_workspace_id = var.law_id
  targets_resource_id = [
    azurerm_postgresql_flexible_server.postgresql_flexible_server.id
    azurerm_storage_account.sa.id,
    join("", [azurerm_storage_account.sa.id, "/blobServices/default"]),
    join("", [azurerm_storage_account.sa.id, "/fileServices/default"])]
}
```
