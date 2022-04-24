variable "rancher_server_devops_resource_group_name" {
  type        = string
  description = "The name of the resource group that contains terraform state"
}

variable "rancher_server_devops_tfstate_storage_account_name" {
  type        = string
  description = "The name of the storage account that contains terraform state"
}

variable "rancher_server_name" {
  type        = string
  description = "the name or path of that the rancher server tfstate is contained in"
  default     = "rancher_server_cluster"
}

variable "rancher_server_cluster_name" {
  type        = string
  description = "The name of the rancher server kubernetes cluster - this should match the value of the context in kubeconfig"
  default     = "aks-rancher-server-01"
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to all resources that are created"
  default     = {}
}
