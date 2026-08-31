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
  description = "(Optional) Scaleway region for the cluster control plane."
  type        = string
}

variable "zone" {
  description = "(Optional) Scaleway zone for the node pool."
  type        = string
}

#    $$\   $$\  $$$$$$\   $$$$$$\
#    $$ | $$  |$$  __$$\ $$  __$$\
#    $$ |$$  / $$ /  $$ |$$ /  \__|
#    $$$$$  /   $$$$$$  |\$$$$$$\
#    $$  $$<   $$  __$$<  \____$$\
#    $$ |\$$\  $$ /  $$ |$$\   $$ |
#    $$ | \$$\ \$$$$$$  |\$$$$$$  |
#    \__|  \__| \______/  \______/
#
#
#

variable "name" {
  description = "(Required) The name for the Kubernetes cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "(Required) The version of the Kubernetes cluster."
  type        = string
}

variable "cni" {
  description = "(Required) The Container Network Interface (CNI) for the Kubernetes cluster. Important: Updates to this field will recreate a new resource."
  type        = string
}

variable "cluster_type" {
  description = "(Optional) Cluster type: kapsule (free) or kapsule-dedicated."
  type        = string
  default     = "kapsule"
}

variable "allowed_ip_ranges" {
  description = "(Optional) Set a definitive list of IP ranges (in CIDR notation) allowed to connect to the API server."
  type        = list(string)
  default     = []
}

variable "private_network_id" {
  description = "(Required) The ID of the private network of the cluster."
  type        = string
}

variable "pod_cidr" {
  description = "(Optional) The subnet used for the Pod CIDR."
  type        = string
}

variable "service_cidr" {
  description = "(Optional) The subnet used for the Service CIDR."
  type        = string
}

variable "service_dns_ip" {
  description = "(Optional) The IP used for the DNS Service. If unset, defaults to Service CIDR's network + 10."
  type        = string
}

variable "delete_additional_resources" {
  description = "(Required) Delete additional resources like block volumes, load-balancers and the cluster's private network (if empty) that were created in Kubernetes on cluster deletion. Important: Setting this field to true means that you will lose all your cluster data and network configuration when you delete your cluster. If you prefer keeping it, you should instead set it as false.."
  type        = bool
  default     = false
}

#    $$$$$$$\   $$$$$$\   $$$$$$\  $$\
#    $$  __$$\ $$  __$$\ $$  __$$\ $$ |
#    $$ |  $$ |$$ /  $$ |$$ /  $$ |$$ |
#    $$$$$$$  |$$ |  $$ |$$ |  $$ |$$ |
#    $$  ____/ $$ |  $$ |$$ |  $$ |$$ |
#    $$ |      $$ |  $$ |$$ |  $$ |$$ |
#    $$ |       $$$$$$  | $$$$$$  |$$$$$$$$\
#    \__|       \______/  \______/ \________|
#
#
#

variable "pool_name" {
  description = "(Required) The name for the pool."
  type        = string
}

variable "pool_node_type" {
  description = "(Required) The commercial type of the pool instances."
  type        = string
}

variable "pool_size" {
  description = "(Required) The size of the pool. This field will only be used at creation if autoscaling is enabled."
  type        = number
}

variable "pool_min_size" {
  description = "(Defaults to 1 if size > 0, or 0 otherwise) The minimum size of the pool, used by the autoscaling feature."
  type        = number
}

variable "pool_max_size" {
  description = "(Defaults to size) The maximum size of the pool, used by the autoscaling feature."
  type        = number
}

variable "pool_root_volume_size_in_gb" {
  description = "(Optional) The size of the system volume of the nodes in gigabyte."
  type        = number
}
