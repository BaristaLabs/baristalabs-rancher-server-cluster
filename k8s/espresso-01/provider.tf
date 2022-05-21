provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "espresso-01"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "espresso-01"
  }
}

provider "kubectl" {
  config_path    = "~/.kube/config"
  config_context = "espresso-01"
}
