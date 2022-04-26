provider "azurerm" {
  features {}
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.rancher_server_cluster_name
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = var.rancher_server_cluster_name
  }
}

provider "kubectl" {
  config_path    = "~/.kube/config"
  config_context = var.rancher_server_cluster_name
}
