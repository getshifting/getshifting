variable "name" {
  description = "(Required) Specifies the name of the Log Analytics Workspace. Workspace name should include 4-63 letters, digits or '-'. The '-' shouldn't be the first or the last symbol. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which the Log Analytics workspace is created. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "sku" {
  description = "(Optional) Specifies the SKU of the Log Analytics Workspace. Possible values are PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, and PerGB2018 (new SKU as of 2018-04-03). Defaults to PerGB2018"
  type        = string
}

variable "retention_in_days" {
  description = "(Optional) The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730."
  type        = number
}

variable "daily_quota_gb" {
  description = "(Optional) The workspace daily quota for ingestion in GB. Defaults to -1 (unlimited) if omitted."
  type        = number
}

variable "internet_ingestion_enabled" {
  description = "(Optional) Should the Log Analytics Workspace support ingestion over the Public Internet? Defaults to true."
  type        = bool
}

variable "internet_query_enabled" {
  description = "(Optional) Should the Log Analytics Workspace support querying over the Public Internet? Defaults to true."
  type        = bool
}

variable "tags" {
  description = "A map of tags to assign to the Log Analytics Workspace"
  type        = map(string)
}