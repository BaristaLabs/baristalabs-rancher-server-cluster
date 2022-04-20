data "azurerm_client_config" "current" {}

locals {
  tags = {
    Creator     = "terraform-baristalabs-rancher-server",
    Environment = "rancher-server-devops",
  }
}

module "rancher_server_devops" {
  source = "../../modules/azurerm_rancher_server_devops"

  az_region = "eastus2"
  tenant_id = data.azurerm_client_config.current.tenant_id

  rancher_server_devops_enable_tfstate_delete_lock = var.rancher_server_devops_enable_tfstate_delete_lock

  rancher_server_devops_resource_group_name = "rg-rancher-server-devops"

  rancher_server_devops_tfstate_storage_account_name             = "stblrstfstate"
  rancher_server_devops_tfstate_storage_account_replication_type = "LRS"

  rancher_server_devops_assets_storage_account_name = "stblrsdevops"
  rancher_server_devops_assets_path                 = "../../assets"
  rancher_server_devops_assets_glob                 = "**"

  rancher_server_devops_service_principal_object_id = data.azurerm_client_config.current.object_id

  rancher_server_devops_key_vault_soft_delete_retention_days = 7

  tags = local.tags
}
