data "terraform_remote_state" "rancher_server_devops" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.rancher_server_devops_resource_group_name
    storage_account_name = var.rancher_server_devops_tfstate_storage_account_name
    container_name       = "tfstate"
    key                  = "rancher_server_devops/terraform.tfstate"
  }
}

data "terraform_remote_state" "rancher_server_cluster" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.rancher_server_devops_resource_group_name
    storage_account_name = var.rancher_server_devops_tfstate_storage_account_name
    container_name       = "tfstate"
    key                  = "${var.rancher_server_name}/terraform.tfstate"
  }
}

# Retrieve naked and root certificates from AKV
data "azurerm_key_vault_certificate_data" "naked_domain_cert" {
  name         = var.naked_domain_cert_akv_name
  key_vault_id = data.terraform_remote_state.rancher_server_devops.outputs.rancher_server_devops_key_vault.id
}

data "azurerm_key_vault_certificate_data" "wildcard_domain_cert" {
  name         = var.wildcard_domain_cert_akv_name
  key_vault_id = data.terraform_remote_state.rancher_server_devops.outputs.rancher_server_devops_key_vault.id
}

# Set up the locals to use for the Rancher Server environment
locals {
  hostname = "baristalabs.io"

  # Namespaces
  rancher_server_namespaces = {
    "rancher_namespace" = "cattle-system"
    "ingress_namespace" = "traefik-ingress"
    "whoami_namespace"  = "whoami"
  }

  # Hostnames
  rancher_server_hostnames = {
    "rancher" = "rancher.${local.hostname}"
    "whoami"  = "whoami.rancher.${local.hostname}"
  }

  tags = merge(var.tags, { Creator = "terraform-baristalabs-rancher-server", Environment = "rancher_server_01" })
}
