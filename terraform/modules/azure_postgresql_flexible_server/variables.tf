variable "name" {
  description = "(Required) The name which should be used for this PostgreSQL Flexible Server. Changing this forces a new PostgreSQL Flexible Server to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the Resource Group where the PostgreSQL Flexible Server should exist. Changing this forces a new PostgreSQL Flexible Server to be created."
  type        = string
}

variable "location" {
  description = "(Required) The Azure Region where the PostgreSQL Flexible Server should exist. Changing this forces a new PostgreSQL Flexible Server to be created."
  type        = string
}

variable "postgresql_flexible_server_version" {
  description = "(Optional) The version of PostgreSQL Flexible Server to use. Possible values are 11,12, 13, 14, 15 and 16. Required when create_mode is Default."
  type        = string
}

variable "administrator_login" {
  description = "(Optional) The Administrator login for the PostgreSQL Flexible Server. Required when create_mode is Default and authentication.password_auth_enabled is true."
  type        = string
}

variable "administrator_password" {
  description = "(Optional) The Password associated with the administrator_login for the PostgreSQL Flexible Server. Required when create_mode is Default and authentication.password_auth_enabled is true."
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "(Optional) The SKU Name for the PostgreSQL Flexible Server. The name of the SKU, follows the tier + name pattern (e.g. B_Standard_B1ms, GP_Standard_D2s_v3, MO_Standard_E4s_v3)."
  type        = string
}

variable "backup_retention_days" {
  description = "(Optional) The backup retention days for the PostgreSQL Flexible Server. Possible values are between 7 and 35 days."
  type        = number
}

variable "geo_redundant_backup_enabled" {
  description = "(Optional) Is Geo-Redundant backup enabled on the PostgreSQL Flexible Server. Defaults to false. Changing this forces a new PostgreSQL Flexible Server to be created."
  type        = bool
}

variable "zone" {
  description = "(Optional) Specifies the Availability Zone in which the PostgreSQL Flexible Server should be located."
  type        = string
}

variable "high_availability_mode" {
  description = "(Required) The high availability mode for the PostgreSQL Flexible Server. Possible value are SameZone or ZoneRedundant."
  type        = string
}

variable "standby_availability_zone" {
  description = "(Optional) Specifies the Availability Zone in which the standby Flexible Server should be located."
  type        = string
}

variable "storage_mb" {
  description = "(Optional) The max storage allowed for the PostgreSQL Flexible Server. Possible values are 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 4194304, 8388608, 16777216 and 33553408."
  type        = number
}

variable "storage_tier" {
  description = "(Optional) The name of storage performance tier for IOPS of the PostgreSQL Flexible Server. Possible values are P4, P6, P10, P15,P20, P30,P40, P50,P60, P70 or P80. Default value is dependant on the storage_mb value. Please see the storage_tier defaults based on storage_mb table below."
  type        = string
}

variable "public_network_access_enabled" {
  description = "(Optional) Specifies whether this PostgreSQL Flexible Server is publicly accessible. Defaults to true."
  type        = bool
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(any)
  default     = {}
}
