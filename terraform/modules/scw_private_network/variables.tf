variable "name" {
  description = "(Required) Name of the private network."
  type        = string
}

variable "vpc_id" {
  description = "(Required) ID of the parent VPC."
  type        = string
}

variable "region" {
  description = "(Required) Scaleway region."
  type        = string
}

variable "ipv4_subnet" {
  description = "(Required) IPv4 CIDR for the private network"
  type        = string
}
