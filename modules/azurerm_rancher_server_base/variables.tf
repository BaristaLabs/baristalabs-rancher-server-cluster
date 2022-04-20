variable "az_region" {
  type        = string
  description = "Azure region in which to provision resources"
}

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
  description = "key vault to store environment-related secrets"
}

variable "use_application_insights" {
  type = bool
  description = "Indicates if application insights resources will be created for the environment"
  default = true
}

variable "use_log_analytics" {
  type = bool
  description = "Indicates if application insights resources will be created for the environment"
  default = true
}

variable "log_retention" {
  type        = number
  description = "The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730"
  default     = 30
}

variable "use_container_insights" {
  type        = bool
  description = "Indicates if Container Insights should be enabled. Default is false."
  default     = false
}

variable "rancher_server_subnet_name" {
  type        = string
  description = "Name of the Rancher Server subnet"
}

variable "rancher_server_aks_subnet_name" {
  type        = string
  description = "Name of the Rancher Server Kubernetes subnet"
}

variable "rancher_server_vnet_cidr" {
  type        = string
  description = "Address Space CIDR of the Rancher Server vNet"
}

variable "rancher_server_subnet_cidr" {
  type        = string
  description = "Address Space CIDR of the Rancher Server subnet"
}

variable "rancher_server_aks_subnet_cidr" {
  type        = string
  description = "Address Space CIDR of the Rancher Server aks subnet"
}

variable "only_allow_frontdoor_traffic" {
  type = bool
  description = "Indicates if the nsg associated with the ingress will prevent all traffic except Azure.FrontDoor tag"
  default = true
}

variable "use_vnet_peer" {
  type = bool
  description = "Indicates if the vnet created will be peered with another virtual network"
  default = false 
}

variable "peer_virtual_network_resource_group_name" {
  type = string
  description = "Indicates the resource group name of the peer virtual network"
  default = null
}

variable "peer_virtual_network_id" {
  type = string
  description = "Indicates the id of the peer virtual network"
  default = null
}

variable "peer_virtual_network_name" {
  type = string
  description = "Indicates the name of the peer virtual network"
  default = null
}

variable "rancher_server_ip_whitelist" {
  type        = list(string)
  description = "IP whitelist of external traffic. Leave null to allow all traffic. This value is ignored if only_allow_frontdoor_traffic is set to true."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to all resources that are created"
}
