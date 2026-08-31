variable "eventhub_namespace_name" {
  description = " (Required) Specifies the name of the EventHub Namespace resource. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the namespace. Changing this forces a new resource to be created."
  type        = string
}

variable "eventhub_namespace_sku" {
  description = "(Required) Defines which tier to use. Valid options are Basic, Standard, and Premium. Please note that setting this field to Premium will force the creation of a new resource."
  type        = string
  default     = "Basic"
}

variable "eventhub_namespace_capacity" {
  description = "(Optional) Specifies the Capacity / Throughput Units for a Standard SKU namespace. Default capacity has a maximum of 2, but can be increased in blocks of 2 on a committed purchase basis. Defaults to 1."
  type        = number
  default     = 1
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(any)
  default     = {}
}

variable "subscription_id" {
  description = "(Required) Specifies the subscription ID"
  type        = string
}

variable "eventgrid_system_topic_name" {
  description = "(Required) The name which should be used for this Event Grid System Topic. Changing this forces a new Event Grid System Topic to be created."
  type        = string
}

variable "eventhub_storage_account_id" {
  description = "The ID of the storage account to handle events for"
  type        = string
}

variable "eventgrid_system_topic_event_subscription_name" {
  description = "(Required) The name which should be used for this Event Subscription. Changing this forces a new Event Subscription to be created."
  type        = string
}

variable "eventhub_name" {
  description = "(Required) Specifies the name of the EventHub. Changing this forces a new resource to be created."
  type        = string
}
