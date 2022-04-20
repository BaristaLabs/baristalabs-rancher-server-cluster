variable "rancher_server_devops_resource_group_name" {
  type        = string
  description = "The name of the resource group that contains terraform state"
}

variable "rancher_server_devops_tfstate_storage_account_name" {
  type        = string
  description = "The name of the storage account that contains terraform state"
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to all resources that are created"
  default     = {}
}
