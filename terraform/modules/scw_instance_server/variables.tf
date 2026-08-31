variable "project_id" {
  description = " (Defaults to provider project_id) The ID of the project the server is associated with."
  type        = string
}

variable "zone" {
  description = "(Defaults to provider zone) The zone in which the server should be created."
  type        = string
}

variable "name" {
  description = "(Optional) The name of the server."
  type        = string
}

variable "type" {
  description = "(Required) The commercial type of the server. You find all the available types on the pricing page. Updates to this field will migrate the server, local storage constraint must be respected. More info. Use replace_on_type_change to trigger replacement instead of migration."
  type        = string
}

variable "image" {
  description = "(Optional) The UUID or the label of the base image used by the server. You can check the available labels with our CLI; `scw marketplace image list`"
  type        = string
}

variable "tags" {
  description = "(Optional) The tags associated with the server."
  type        = list(string)
  default     = []
}

variable "root_volume_size" {
  description = "(Required) Size of the root volume in gigabytes. To find the right size use this endpoint and check the volumes_constraint."
  type        = number
}

variable "ip_address" {
  description = "(Required) Private IP address to reserve from IPAM for the server."
  type        = string
}

variable "private_network_id" {
  description = "(Required) The ID of the private network to attach the server to."
  type        = string
}
