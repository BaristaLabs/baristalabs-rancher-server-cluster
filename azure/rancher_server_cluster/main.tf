data "terraform_remote_state" "rancher_server_devops" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.rancher_server_devops_resource_group_name
    storage_account_name = var.rancher_server_devops_tfstate_storage_account_name
    container_name       = "tfstate"
    key                  = "rancher_server_devops/terraform.tfstate"
  }
}

locals {
  az_region          = "eastus2"
  environment        = "01"
  environment_prefix = "rancher-server"

  tags = merge(var.tags, { Creator = "terraform-baristalabs-rancher-server", Environment = "rancher-server-01" })
}

### Provision the environment resources
module "rancher_server" {
  source = "../../modules/azurerm_rancher_server_base"

  az_region          = local.az_region
  environment        = local.environment
  environment_prefix = local.environment_prefix

  rancher_server_devops_key_vault = data.terraform_remote_state.rancher_server_devops.outputs.rancher_server_devops_key_vault

  use_application_insights = false
  use_log_analytics        = false
  use_container_insights   = false

  only_allow_frontdoor_traffic = false
  rancher_server_ip_whitelist  = null

  rancher_server_vnet_cidr = "10.10.0.0/22" # 1024 ips 10.10.0.0 - 10.10.3.255

  rancher_server_subnet_name = "snet-blrs-01"
  rancher_server_subnet_cidr = "10.10.0.0/23" # 10.10.0.0 - 10.10.1.255

  rancher_server_aks_subnet_name = "snet-blrs-01-aks"
  rancher_server_aks_subnet_cidr = "10.10.2.0/23" # 10.10.2.0 - 10.10.3.255

  use_vnet_peer = false

  tags = local.tags
}

### Provision AKS
module "rancher_server_cluster" {
  source = "../../modules/azurerm_rancher_server_cluster"

  environment        = local.environment
  environment_prefix = local.environment_prefix

  rancher_server_devops_key_vault = data.terraform_remote_state.rancher_server_devops.outputs.rancher_server_devops_key_vault

  rancher_server_resource_group = module.rancher_server.rancher_server_resource_group

  rancher_server_subnet     = module.rancher_server.rancher_server_subnet
  rancher_server_aks_subnet = module.rancher_server.rancher_server_aks_subnet

  rancher_server_log_analytics_workspace = module.rancher_server.rancher_server_log_analytics_workspace

  rancher_server_cluster_agent_node_size  = "Standard_D2s_v4"
  rancher_server_cluster_agent_node_count = 1
  rancher_server_cluster_azs              = null
  rancher_server_cluster_sku_tier         = "Free"

  rancher_server_user_node_pools = {
    workerpool01 = {
      layer_name      = "ha"
      node_size       = "Standard_D2s_v4"
      node_count      = 1
      os_type         = "Linux"
      os_disk_size_gb = 64
      node_taints     = []
    }
  }

  tags = local.tags
}
