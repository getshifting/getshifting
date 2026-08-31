variable "name" {
  description = "(Required) Name of the Scaleway VPC."
  type        = string
}

variable "region" {
  description = "(Optional) Scaleway region the VPC is created in."
  type        = string
}

variable "project_id" {
  description = "(Required) Scaleway project ID the VPC belongs to."
  type        = string
}

variable "tags" {
  description = "(Optional) Tags applied to the VPC."
  type        = list(string)
  default     = []
}
