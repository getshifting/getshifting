#     $$$$$$\  $$$$$$$$\ $$\   $$\ $$$$$$$$\ $$$$$$$\   $$$$$$\  $$\
#    $$  __$$\ $$  _____|$$$\  $$ |$$  _____|$$  __$$\ $$  __$$\ $$ |
#    $$ /  \__|$$ |      $$$$\ $$ |$$ |      $$ |  $$ |$$ /  $$ |$$ |
#    $$ |$$$$\ $$$$$\    $$ $$\$$ |$$$$$\    $$$$$$$  |$$$$$$$$ |$$ |
#    $$ |\_$$ |$$  __|   $$ \$$$$ |$$  __|   $$  __$$< $$  __$$ |$$ |
#    $$ |  $$ |$$ |      $$ |\$$$ |$$ |      $$ |  $$ |$$ |  $$ |$$ |
#    \$$$$$$  |$$$$$$$$\ $$ | \$$ |$$$$$$$$\ $$ |  $$ |$$ |  $$ |$$$$$$$$\
#     \______/ \________|\__|  \__|\________|\__|  \__|\__|  \__|\________|
#
#
#

variable "env_subscription_id" {
  description = "(Required) Specifies the subscription ID of the current environment"
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Specifies the name of the resource group."
  type        = string
}

variable "location" {
  description = "(Optional) Specifies the location for the resource group and all the resources"
  type        = string
}

variable "tags" {
  description = "(Required) Specifies tags for all the resources"
  type        = map(string)
}

#    $$$$$$$$\ $$\    $$\ $$$$$$$$\ $$\   $$\ $$$$$$$$\ $$\   $$\ $$\   $$\ $$$$$$$\
#    $$  _____|$$ |   $$ |$$  _____|$$$\  $$ |\__$$  __|$$ |  $$ |$$ |  $$ |$$  __$$\
#    $$ |      $$ |   $$ |$$ |      $$$$\ $$ |   $$ |   $$ |  $$ |$$ |  $$ |$$ |  $$ |
#    $$$$$\    \$$\  $$  |$$$$$\    $$ $$\$$ |   $$ |   $$$$$$$$ |$$ |  $$ |$$$$$$$\ |
#    $$  __|    \$$\$$  / $$  __|   $$ \$$$$ |   $$ |   $$  __$$ |$$ |  $$ |$$  __$$\
#    $$ |        \$$$  /  $$ |      $$ |\$$$ |   $$ |   $$ |  $$ |$$ |  $$ |$$ |  $$ |
#    $$$$$$$$\    \$  /   $$$$$$$$\ $$ | \$$ |   $$ |   $$ |  $$ |\$$$$$$  |$$$$$$$  |
#    \________|    \_/    \________|\__|  \__|   \__|   \__|  \__| \______/ \_______/
#
#
#

variable "deploy_eventhub" {
  description = "(Optional) Specifies if the Eventhub resources should be deployed"
  type        = bool
  default     = false
}

variable "eventhub_namespace_name" {
  description = " (Required) Specifies the name of the EventHub Namespace resource. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "eventhub_namespace_private_endpoint_ip_configurations" {
  description = "(Optional) Specifies the static IP addresses within the private endpoint's subnet to be used. Changing this forces a new resource to be created."
  default     = []
  type        = list(object({ private_ip_address = string, member_name = string }))
}

variable "eventgrid_system_topic_name" {
  description = "(Required) The name which should be used for this Event Grid System Topic. Changing this forces a new Event Grid System Topic to be created."
  type        = string
  default     = null
}

variable "eventhub_storage_account_id" {
  description = "The ID of the storage account to handle events for"
  type        = string
  default     = null
}

variable "eventhub_storage_account_name" {
  description = "The name of the storage account to handle events for"
  type        = string
  default     = null
}

variable "eventgrid_system_topic_event_subscription_name" {
  description = "(Required) The name which should be used for this Event Subscription. Changing this forces a new Event Subscription to be created."
  type        = string
  default     = null
}

variable "eventhub_name" {
  description = "(Required) Specifies the name of the EventHub. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "eventhub_tags" {
  description = "(Required) Specifies tags for the EventHub resources"
  type        = map(string)
}

#    $$\   $$\ $$$$$$$$\ $$$$$$$$\ $$\      $$\  $$$$$$\  $$$$$$$\  $$\   $$\
#    $$$\  $$ |$$  _____|\__$$  __|$$ | $\  $$ |$$  __$$\ $$  __$$\ $$ | $$  |
#    $$$$\ $$ |$$ |         $$ |   $$ |$$$\ $$ |$$ /  $$ |$$ |  $$ |$$ |$$  /
#    $$ $$\$$ |$$$$$\       $$ |   $$ $$ $$\$$ |$$ |  $$ |$$$$$$$  |$$$$$  /
#    $$ \$$$$ |$$  __|      $$ |   $$$$  _$$$$ |$$ |  $$ |$$  __$$< $$  $$<
#    $$ |\$$$ |$$ |         $$ |   $$$  / \$$$ |$$ |  $$ |$$ |  $$ |$$ |\$$\
#    $$ | \$$ |$$$$$$$$\    $$ |   $$  /   \$$ | $$$$$$  |$$ |  $$ |$$ | \$$\
#    \__|  \__|\________|   \__|   \__/     \__| \______/ \__|  \__|\__|  \__|
#
#
#

variable "deploy_eventhub_pep" {
  description = "(Optional) Specifies if the EventHub Private Endpoint should be deployed"
  type        = bool
  default     = false
}

variable "vnet_name" {
  description = "(Required) The name of the virtual network. Changing this forces a new resource to be created."
  type        = string
}

variable "subnet_name" {
  description = "(Required) The name of the subnet."
  type        = string
}

variable "eventhub_private_endpoint_ip_configurations" {
  description = "(Optional) Specifies the static IP addresses within the private endpoint's subnet to be used for the EventHub. Changing this forces a new resource to be created."
  default     = []
  type = list(object({
    private_ip_address = string,
    member_name = string }
  ))
}

variable "storageaccount_private_endpoint_ip_configurations" {
  description = "(Optional) Specifies the static IP addresses within the private endpoint's subnet to be used for the Storage Account. Changing this forces a new resource to be created."
  default     = []
  type = list(object({
    private_ip_address = string,
    member_name = string }
  ))
}

variable "privatezone_eventhub" {
  description = " The name of the Private DNS Zone for EventHub."
  type        = string
}

variable "privatezone_blob" {
  description = " The name of the Private DNS Zone for Blob storage."
  type        = string
}

#    $$\       $$$$$$\   $$$$$$\   $$$$$$\
#    $$ |     $$  __$$\ $$  __$$\ $$  __$$\
#    $$ |     $$ /  $$ |$$ /  \__|$$ /  \__|
#    $$ |     $$ |  $$ |$$ |$$$$\ \$$$$$$\
#    $$ |     $$ |  $$ |$$ |\_$$ | \____$$\
#    $$ |     $$ |  $$ |$$ |  $$ |$$\   $$ |
#    $$$$$$$$\ $$$$$$  |\$$$$$$  |\$$$$$$  |
#    \________|\______/  \______/  \______/
#
#
#

variable "deploy_eventhub_logs" {
  description = "(Optional) Specifies if the EventHub logging and diagnostics should be deployed"
  type        = bool
  default     = false
}

variable "law_name" {
  description = "(Required) Specifies the name of the Log Analytics Workspace. Workspace name should include 4-63 letters, digits or '-'. The '-' shouldn't be the first or the last symbol. Changing this forces a new resource to be created."
  type        = string
}
