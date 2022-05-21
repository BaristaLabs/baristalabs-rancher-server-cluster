terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.11.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~>2.5.1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~>1.11.3"
    }
  }
  required_version = "~> 1.2.0"
}