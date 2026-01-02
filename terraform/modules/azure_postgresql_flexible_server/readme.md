# PostgreSql Flexible Server

This module is the replacement for the PostgreSql Standalone server which retired in March 2025.

## Wiki and usage

For more information about this module, see [this wiki page](https://wiki.getshifting.com/terraformmodulepostgresqlflexibleserver).

This module is used by the [postgresql application](../../apps/postgresql.tf)

## Useful links

- [Terraform registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server)
- [Azure Database for PostgreSQL - Flexible Server documentation](https://learn.microsoft.com/en-us/azure/postgresql/)

## Notes

- version = "16" : requires newer version (3.110) for azurerm provider

- compute:
  - sku_name = "GP_Standard_D2s_v3" // Standard_D2s_v3 (2 vCores, 8 GiB memory, 3200 max iops)

- zone = "3" : This is the availability zone in which the server will be deployed
  - Note: I removed this option because of an error during the deployment. I suspect the resources in West Europe in zone 1 and 2 to be scarce. When removing the zone preference the deployment succeeded in zone 3.

Backup:

- backup_retention_days = 8 : backups are retained for 8 days
- geo_redundant_backup_enabled = true : backup redundancy is set to Geo-Redundant

- [high_availability](https://learn.microsoft.com/en-us/azure/reliability/reliability-postgresql-flexible-server#availability-zone-support)
  - mode = "SameZone" : high availability is set for the same zone, so if the server crashes another server is (immediately) available. If we want to protect for zone failure we need the following settings:
    - mode                      = "ZoneRedundant"
    - standby_availability_zone = "1"

> Even though the region 'West Europe' is enabled for ZoneRedundant deployments, such deployments are temporarily [blocked](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/overview#azure-regions)

### Procedure to move to 'ZoneRedundant' once possible

- Disable HA (could be done in the portal or by commenting out the 'high_availability' block in the tf module)
- Configure the high_availability block as described above

- [Storage size and tier](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server#storage_tier-defaults-based-on-storage_mb)
  - storage_mb   = 32768
  - storage_tier = "P6" // default = "P4" // P6 (240 iops)

## More information on high availability

Zonal (SameZone in terraform) offers SLA uptime of 99.95%. Zone-redundancy offers [99.99%](https://learn.microsoft.com/en-us/azure/reliability/reliability-postgresql-flexible-server#sla)

## Restore a server

[Restore a server (PITR/GeoRestore)](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-restore-server-portal)
