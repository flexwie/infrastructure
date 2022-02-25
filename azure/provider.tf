terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.96.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.18.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.13.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.8.0"
    }
    local = {
      version = "~> 2.1"
    }
  }
}
