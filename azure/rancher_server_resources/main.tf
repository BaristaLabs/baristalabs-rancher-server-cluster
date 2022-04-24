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

# Set up the locals to use for the Rancher Server environment
locals {
  hostname = "baristalabs.io"

  # Namespaces
  rancher_server_namespaces = {
    "cert_manager_namespace" = "cert-manager"
    "rancher_namespace" = "cattle-system"
    "traefik_namespace" = "traefik-system"
    "whoami_namespace"  = "whoami"
  }

  # Hostnames
  rancher_server_hostnames = {
    "rancher" = "rancher.${local.hostname}"
    "whoami"  = "whoami.rancher.${local.hostname}"
  }

  cert_admin_email       = "sean@baristalabs.io"
  cert_ca_use_production = false

  tags = merge(var.tags, { Creator = "terraform-baristalabs-rancher-server", Environment = "rancher_server_01" })
}
