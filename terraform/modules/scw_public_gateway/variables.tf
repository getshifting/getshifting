variable "name" {
  description = "(Optional) The name for the Public Gateway. If not provided it will be randomly generated."
  type        = string
}

variable "zone" {
  description = "(Defaults to provider zone) The zone in which the Public Gateway should be created."
  type        = string
}

variable "type" {
  description = "(Required) The gateway type (size)."
  type        = string
}

variable "private_network_attachments" {
  description = "(Required) Map of attachment-key -> object with private_network_id and optional push_default_route. Each entry creates one scaleway_vpc_gateway_network resource."
  type = map(object({
    private_network_id = string
    push_default_route = optional(bool, true)
  }))
}

variable "allowed_ip_ranges" {
  description = "(Optional) Set a definitive list of IP ranges (in CIDR notation) allowed to connect to the SSH bastion."
  type        = list(string)
  default     = []
}

variable "ssh_key_id" {
  description = "(Required) The ID of the SSH key to use for the bastion host."
  type        = string
}
