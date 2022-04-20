variable "rancher_server_devops_enable_tfstate_delete_lock" {
  type        = bool
  description = "(Optional) True to enable a storage-account scoped lock that prevents deletion of the tfstate storage account and contained resources"
  default     = true
}
