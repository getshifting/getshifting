# Log Analytics Workspace

This module deploys a log analytics workspace.

## Usage

This module is used by the [postgresql application](../../apps/postgresql.tf)

## Resources

[Log Analytics workspace overview](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview)
[Terraform Registry log_analytics_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace)

## AMPLS

Note: For azure monitor, in the hub and spoke design, you'd use a single [AMPLS](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/private-link-design#hub-and-spoke-networks) to make the log analytics a private resource. However, if there are also log analytics in subscriptions and resource groups without private networks this will have the following implications:

Warnings from the [docs](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/private-link-security):

```text
Because Azure Monitor uses some shared endpoints (meaning endpoints that aren't resource specific), setting up a private link even for a single resource changes the DNS configuration that affects traffic to all resources. In other words, traffic to all workspaces or components is affected by a single private link setup.

​Creating a private link affects traffic to all monitoring resources, not only resources in your AMPLS. Effectively, it will cause all query requests and ingestion to Application Insights components to go through private IPs. It doesn't mean the private link validation applies to all these requests.

Resources not added to the AMPLS can only be reached if the AMPLS access mode is Open and the target resource accepts traffic from public networks. When you use the private IP, private link validations don't apply to resources not in the AMPLS. To learn more, see Private Link access modes.

Private Link settings for Managed Prometheus and ingesting data into your Azure Monitor workspace are configured on the Data Collection Endpoints for the referenced resource. Settings for querying your Azure Monitor workspace over Private Link are made directly on the Azure Monitor workspace and are not handled via AMPLS.
```
