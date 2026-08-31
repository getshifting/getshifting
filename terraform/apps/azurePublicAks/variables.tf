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

variable "allowed_cidrs" {
  description = "(Required) Specifies the CIDR ranges allowed to access Azure resources"
  type        = list(string)
}

#     $$$$$$\  $$\   $$\  $$$$$$\
#    $$  __$$\ $$ | $$  |$$  __$$\
#    $$ /  $$ |$$ |$$  / $$ /  \__|
#    $$$$$$$$ |$$$$$  /  \$$$$$$\
#    $$  __$$ |$$  $$<    \____$$\
#    $$ |  $$ |$$ |\$$\  $$\   $$ |
#    $$ |  $$ |$$ | \$$\ \$$$$$$  |
#    \__|  \__|\__|  \__| \______/
#
#
#

variable "aks_admins" {
  description = "(Required) Specifies the object ID of the Azure AD group that will be assigned as AKS Admins"
  type        = string
}

variable "kube_config_path" {
  description = "(Optional) Specifies the path to save the kubeconfig file"
  type        = string
  default     = "C:/Users/aks/.kube/aks_public_user.yaml"
}

variable "tls_cert_path" {
  description = "(Optional) Specifies the path to save the TLS certificate file"
  type        = string
  default     = "C:/Users/aks/.kube/aks_public_tls.crt"
}

variable "deploy_k8s_resources" {
  description = "(Optional) Deploy Kubernetes resources after AKS provisioning is complete"
  type        = bool
  default     = false
}

variable "fqdn" {
  description = "(Required) Specifies the fully qualified domain name for the AKS cluster"
  type        = string
  default     = "aks.getshifting.com"
}
