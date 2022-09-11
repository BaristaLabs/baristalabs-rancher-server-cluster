data "azurerm_client_config" "current" {}

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
  # Namespaces
  rancher_server_namespaces = {
    cert_manager_namespace = "cert-manager"
    rancher_namespace = "cattle-system"
    traefik_namespace = "traefik-system"
    whoami_namespace  = "whoami"
    tailscale_namespace  = "tailscale"
    coredns_external_namespace = "coredns-external"

    domain_namespace      = "baristalabs"
    homelab_01_namespace = "homelab-01"
  }

  # Hostnames
  rancher_server_hostnames = {
    whoami  = "whoami.${data.terraform_remote_state.rancher_server_cluster.outputs.rancher_server_cluster_hostname}"
  }

  homelab_01_hostnames = {
    grafana      = "grafana.baristalabs.io"

    whoami       = "whoami.baristalabs.io"
    whoami2      = "whoami.treasuryecm.rdaprojects.com"
  }

  cert_admin_email       = "sean@baristalabs.io"

  root_hostname          = "baristalabs.io"
  redirect_url           = "https://www.baristalabs.io"

  tags = merge(var.tags, { Creator = "terraform-baristalabs-rancher-server", Environment = "rancher_server_01" })
}
