terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">=1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.5.1"
    }
  }
  required_version = ">= 1.2.0"
}