# See https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging
variable "environment" {
  type        = string
  description = "name of the environment"
}

variable "environment_prefix" {
  type        = string
  description = "environment prefix of resources"
}

variable "rancher_server_devops_key_vault" {
  type = object({
    id = string
  })
  description = "name of the key vault to store kubernetes secrets after creation"
}

variable "rancher_server_resource_group" {
  type = object({
    id       = string
    name     = string
    location = string
  })
  description = "name of the environment resource group"
}

variable "rancher_server_subnet" {
  type = object({
    id = string
  })
  description = "Rancher Server subnet"
}

variable "rancher_server_aks_subnet" {
  type = object({
    id = string
  })
  description = "Rancher Server aks subnet"
}

variable "rancher_server_log_analytics_workspace" {
  type = object({
    id = string
  })
  description = "Rancher Server log analytics workspace"
}

variable "rancher_server_cluster_dns_prefix" {
  type        = string
  description = "the, uhm, prefix-prefix to use for the kubernetes dns environment. Example: sc"
  default     = null
}

variable "rancher_server_cluster_version" {
  type        = string
  description = "the kubernetes version to use. Get supported versions for a region using az aks get-versions --location <location>"
  default     = "1.22.6"
}

variable "rancher_server_cluster_azs" {
  type        = list(number)
  description = "the azs to use for the kubernetes cluster"
  default     = [1, 2, 3]
}

variable "rancher_server_cluster_sku_tier" {
  type        = string
  description = "Free or Paid - This controls if one is charged for an SLA agreement"
  default     = "Free"

  validation {
    condition     = can(regex("^(Free|Paid)$", var.rancher_server_cluster_sku_tier))
    error_message = "The rancher_server_kubernetes_sku_tier value must be either Free or Paid."
  }
}

variable "rancher_server_cluster_agent_node_size" {
  type        = string
  description = "the size of the agent nodes"
}

variable "rancher_server_cluster_agent_node_count" {
  type        = number
  description = "initial number of agent nodes"
}

variable "rancher_server_user_node_pools" {
  type = map(object({
    os_type         = string
    layer_name      = string
    node_size       = string
    node_count      = number
    node_taints     = list(string)
    os_disk_size_gb = number
  }))
  description = "A map of the Rancher Server user node pools to create"
  default     = {}
}

variable "rancher_server_spot_node_pools" {
  type = map(object({
    os_type         = string
    layer_name      = string
    node_size       = string
    node_count      = number
    node_taints     = list(string)
    os_disk_size_gb = number
    spot_max_price  = number
  }))
  description = "A map of the Rancher Server user node pools to create"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to all resources that are created"
}