terraform {
  required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.11.0"
    }

    rancher2 = {
      source = "rancher/rancher2"
      version = "1.24.0"
    }
    

    helm = {
      source  = "hashicorp/helm"
      version = "~>2.5.1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~>1.14.0"
    }
  }
  required_version = "~> 1.2.2"
}