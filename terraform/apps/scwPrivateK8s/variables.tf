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

variable "region" {
  description = "(Required) Scaleway region."
  type        = string
  default     = "nl-ams"
}

variable "zone" {
  description = "(Required) Scaleway zone."
  type        = string
  default     = "nl-ams-1"
}

variable "project_id" {
  description = "(Required) Scaleway project ID."
  type        = string
}

variable "organization_id" {
  description = "(Required) Scaleway organization ID."
  type        = string
}

variable "public_key" {
  description = "(Optional) Your public SSH key. This will be used to create an SSH key in Scaleway."
  type        = string
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

variable "my_ip_address" {
  description = "(Optional) Your public IP address. If provided, it will be used to restrict SSH access to the bastion host. Use the format 'x.x.x.x/32'."
  type        = string
  default     = "0.0.0.0/0"
}
