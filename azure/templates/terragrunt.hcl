remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    resource_group_name = "${rancher_server_devops_resource_group_name}" # Update this to the correct resource group name
    storage_account_name = "${rancher_server_devops_tfstate_storage_account_name}" # Update this to the correct storage account name
    container_name       = "tfstate"
    key = "${path_relative_to_include()}/terraform.tfstate"
  }
}

inputs = {
  rancher_server_devops_resource_group_name = "${rancher_server_devops_resource_group_name}"
  rancher_server_devops_tfstate_storage_account_name = "${rancher_server_devops_tfstate_storage_account_name}"
}

