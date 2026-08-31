# Eventhub

This module deploys an Eventhub, Eventhub namespace, and a .

## Usage

This module is used by the [eventhub application](../../apps/eventhub/eventhub.tf)

## Note about private networks

Even though both the eventhub namespace and the storage account support private endpoints, an eventgrid system topic does not. So, the event notification will come over the public internet to eventhub. Eventhub namespace has the current (February 2026) eventgrid IP addresses from the West Europe in it's firewall exception rules. The latest version of these IP addresses can be found in the [Azure IP Ranges and Service Tags – Public Cloud](https://www.microsoft.com/en-us/download/details.aspx?id=56519).

## Eventhub and grid logs

An overview of all diagnostics for eventhub can be found in log analytics workspace using the following query:

```kusto
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.EVENTHUB"
| sort by TimeGenerated desc
```

Logging for failed deliveries of eventgrid events can be found in log analytics workspace using the following query:

```kusto
AegDeliveryFailureLogs
| sort by TimeGenerated desc
```
