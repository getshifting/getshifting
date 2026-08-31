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

#    $$$$$$$\   $$$$$$\   $$$$$$\ $$$$$$$$\  $$$$$$\  $$$$$$$\  $$$$$$$$\  $$$$$$\   $$$$$$\  $$\
#    $$  __$$\ $$  __$$\ $$  __$$\\__$$  __|$$  __$$\ $$  __$$\ $$  _____|$$  __$$\ $$  __$$\ $$ |
#    $$ |  $$ |$$ /  $$ |$$ /  \__|  $$ |   $$ /  \__|$$ |  $$ |$$ |      $$ /  \__|$$ /  $$ |$$ |
#    $$$$$$$  |$$ |  $$ |\$$$$$$\    $$ |   $$ |$$$$\ $$$$$$$  |$$$$$\    \$$$$$$\  $$ |  $$ |$$ |
#    $$  ____/ $$ |  $$ | \____$$\   $$ |   $$ |\_$$ |$$  __$$< $$  __|    \____$$\ $$ |  $$ |$$ |
#    $$ |      $$ |  $$ |$$\   $$ |  $$ |   $$ |  $$ |$$ |  $$ |$$ |      $$\   $$ |$$ $$\$$ |$$ |
#    $$ |       $$$$$$  |\$$$$$$  |  $$ |   \$$$$$$  |$$ |  $$ |$$$$$$$$\ \$$$$$$  |\$$$$$$ / $$$$$$$$\
#    \__|       \______/  \______/   \__|    \______/ \__|  \__|\________| \______/  \___$$$\ \________|
#                                                                                        \___|
#
#

variable "postgresql_flexible_server_name" {
  description = "(Required) The name which should be used for this PostgreSQL Flexible Server. Changing this forces a new PostgreSQL Flexible Server to be created."
  type        = string
}

variable "postgresql_tags" {
  description = "(Required) Specifies tags for the PostgreSQL resources"
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

variable "deploy_psql_pep" {
  description = "(Optional) Specifies if the PostgreSQL Flexible Server Private Endpoint should be deployed"
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

variable "postgresql_flexible_server_private_endpoint_ip_configurations" {
  description = "(Optional) Specifies the static IP addresses within the private endpoint's subnet to be used for the PostgreSQL Flexible Server. Changing this forces a new resource to be created."
  default     = []
  type = list(object({
    private_ip_address = string,
    member_name = string }
  ))
}

variable "privatezone" {
  description = " The name of the Private DNS Zone."
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

variable "deploy_psql_logs" {
  description = "(Optional) Specifies if the PostgreSQL Flexible Server logging and diagnostics should be deployed"
  type        = bool
  default     = false
}

variable "law_name" {
  description = "(Required) Specifies the name of the Log Analytics Workspace. Workspace name should include 4-63 letters, digits or '-'. The '-' shouldn't be the first or the last symbol. Changing this forces a new resource to be created."
  type        = string
}
