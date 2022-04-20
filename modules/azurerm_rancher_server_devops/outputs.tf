output "rancher_server_devops_resource_group" {
  value = azurerm_resource_group.rancher_server_devops
}

output "rancher_server_devops_tenant_id" {
  value = var.tenant_id
}

output "rancher_server_devops_tfstate_storage_account" {
  value     = azurerm_storage_account.rancher_server_devops_tfstate
  sensitive = true
}

output "rancher_server_devops_tfstate_storage_account_name" {
  value = azurerm_storage_account.rancher_server_devops_tfstate.name
}

output "rancher_server_devops_assets_storage_account" {
  value     = azurerm_storage_account.rancher_server_devops_assets
  sensitive = true
}

output "rancher_server_devops_assets_storage_account_name" {
  value = azurerm_storage_account.rancher_server_devops_assets.name
}

output "rancher_server_devops_managed_identity" {
  value = azurerm_user_assigned_identity.rancher_server_devops
}

output "rancher_server_devops_key_vault" {
  value = azurerm_key_vault.rancher_server_devops
}
