provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "homelab-01"
}

provider "rancher2" {
  api_url    = var.cluster_api_url
  token_key = var.cluster_token_key
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "homelab-01"
  }
}

provider "kubectl" {
  config_path    = "~/.kube/config"
  config_context = "homelab-01"
}
