output "rancher_server_devops_resource_group" {
  value = module.rancher_server_devops.rancher_server_devops_resource_group
}

output "rancher_server_devops_tfstate_storage_account" {
  value     = module.rancher_server_devops.rancher_server_devops_tfstate_storage_account
  sensitive = true
}

output "rancher_server_devops_tfstate_storage_account_name" {
  value = module.rancher_server_devops.rancher_server_devops_tfstate_storage_account_name
}

output "rancher_server_devops_assets_storage_account" {
  value     = module.rancher_server_devops.rancher_server_devops_assets_storage_account
  sensitive = true
}

output "rancher_server_devops_assets_storage_account_name" {
  value = module.rancher_server_devops.rancher_server_devops_assets_storage_account_name
}

output "rancher_server_devops_key_vault" {
  value     = module.rancher_server_devops.rancher_server_devops_key_vault
  sensitive = true
}
