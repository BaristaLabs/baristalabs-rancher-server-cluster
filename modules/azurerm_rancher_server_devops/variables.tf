# See https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging
variable "az_region" {
  type        = string
  description = "Azure region in which to provision resources"
}

variable "tenant_id" {
  type        = string
  description = "tenant id of the environment"
}

variable "rancher_server_devops_enable_tfstate_delete_lock" {
  type        = bool
  description = "(Optional) True to enable a storage-account scoped lock that prevents deletion of the tfstate storage account and contained resources"
  default     = true
}

variable "rancher_server_devops_resource_group_name" {
  type        = string
  description = "(Optional) Name of the resource group that will store rancher server devops resources. Defaults to rg-rancherserver-devops"
  default     = "rg-rancherserver-devops"
}

variable "rancher_server_devops_tfstate_storage_account_name" {
  type        = string
  description = "(Optional) Name of the storage account that will hold terraform state and other provisioning resources. Defaults to stblrstfstate<nonce>"
  default     = "stblrstfstate"
}

variable "rancher_server_devops_tfstate_storage_account_replication_type" {
  type        = string
  description = "(Optional) Replication type of the tfstate resource group. Defaults to LRS."
  default     = "LRS"
}

variable "rancher_server_devops_assets_storage_account_name" {
  type        = string
  description = "(Optional) Name of the Rancher Server DevOps storage account to use. Defaults to stblrsdevops."
  default     = "stblrsdevops"
}

variable "rancher_server_devops_managed_identity_name" {
  type        = string
  description = "(Optional) Name of the rancher server devops managed identity to create."
  default     = "id-blrs-devops"
}

variable "rancher_server_devops_key_vault_name" {
  type        = string
  description = "(Optional) Name of the rancher server devops key vault to create"
  default     = "kv-blrs"
}

variable "rancher_server_devops_key_vault_soft_delete_retention_days" {
  type        = number
  description = "(Optional) Number of days to retain key vault secrets after deleting"
  default     = 90
}

variable "rancher_server_devops_key_vault_purge_protection_enabled" {
  type        = bool
  description = "(Optional) Indicates if purge protection of the key vault resource is enabled. Default is false."
  default     = false
}

variable "rancher_server_devops_service_principal_object_id" {
  type        = string
  description = "(Optional) Object Id of the Service Principal used for deployment (Can be the object id of a user). If not specified, an access policy is not created."
  default     = null
}

variable "rancher_server_devops_assets_path" {
  type        = string
  description = "(Optional) An absolute or relative path to a folder that contains assets to provision into the assets storage container"
  default     = null
}

variable "rancher_server_devops_assets_glob" {
  type        = string
  description = "(Optional) A glob that specifies the assets to provision. Defaults to **"
  default     = "**"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) The tags to apply to all resources that are created"
  default     = {}
}

