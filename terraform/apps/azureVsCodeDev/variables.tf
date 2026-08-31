variable "subscription_id" {
  description = "Subscription ID to deploy into. Leave empty to use Azure CLI/default context."
  type        = string
  default     = ""
}

variable "project" {
  description = "Project label used in resource names."
  type        = string
  default     = "vscode"
}

variable "environment" {
  description = "Environment label used in resource names and tags."
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "Resource group for the VS Code dev host."
  type        = string
  default     = "rg-euw-vscode-dev"
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "westeurope"
}

variable "vm_zone" {
  description = "Availability zone. Set to null in regions without zones."
  type        = string
  default     = "1"
  nullable    = true
}

variable "vm_size" {
  description = "Spot VM size for the host. Note that the default limit for low priority cores is 3. Increase the LowPriorityCores quota for the subscription to use a bigger size."
  type        = string
  default     = "Standard_D2s_v6"
}

variable "admin_username" {
  description = "Admin username used for SSH access and docker group membership."
  type        = string
  default     = "azadmin"
}

variable "admin_ssh_public_key" {
  description = "SSH public key content (single line)."
  type        = string
  default     = "ssh-ed25519"
}

variable "vnet_cidr" {
  description = "CIDR block for the virtual network."
  type        = string
  default     = "10.90.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the VM subnet."
  type        = string
  default     = "10.90.1.0/24"
}

variable "allowed_ssh_cidrs" {
  description = "CIDR ranges allowed to access SSH (port 22)."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "image_publisher" {
  description = "Linux image publisher."
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Linux image offer."
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "Linux image SKU."
  type        = string
  default     = "22_04-lts-gen2"
}

variable "image_version" {
  description = "Linux image version."
  type        = string
  default     = "latest"
}

variable "os_disk_type" {
  description = "Managed disk SKU for the OS disk."
  type        = string
  default     = "Premium_LRS"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB."
  type        = number
  default     = 128
}

variable "max_bid_price_usd" {
  description = "Max spot bid price in USD. -1 means pay up to on-demand price."
  type        = number
  default     = -1
}

variable "enable_auto_shutdown" {
  description = "Whether to configure daily VM auto-shutdown."
  type        = bool
  default     = true
}

variable "auto_shutdown_local_hhmm" {
  description = "Daily auto-shutdown time in local schedule timezone (HHmm)."
  type        = string
  default     = "1800"
}

variable "shutdown_timezone" {
  description = "Timezone for Azure VM auto-shutdown schedule (Windows timezone ID)."
  type        = string
  default     = "W. Europe Standard Time"
}

variable "enable_accelerated_networking" {
  description = "Enable NIC accelerated networking when VM size supports it."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Extra tags applied to all resources."
  type        = map(string)
  default     = {}
}
