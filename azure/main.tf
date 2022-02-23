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

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "cluster"
  location = "germanywestcentral"
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "k8s"

  default_node_pool {
    name       = "system"
    node_count = 1
    vm_size    = "standard_b2s"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "pool" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.cluster.id
  vm_size               = "standard_b2s"
  enable_auto_scaling   = true
  max_count             = 2
  min_count             = 0
  node_count            = 0
}

data "azurerm_kubernetes_cluster" "cluster_data" {
  name                = azurerm_kubernetes_cluster.cluster.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_zone" "dns" {
  name                = "haste.cloud"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_a_record" "argo" {
  name                = "argo"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 60
  records             = ["20.113.41.131"]
}

resource "azurerm_dns_a_record" "fission" {
  name                = "faas"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 60
  records             = ["20.79.198.242"]
}

data "azuread_client_config" "current" {}

resource "azuread_application" "name" {
  display_name     = "ArgoCD Auth"
  sign_in_audience = "AzureADMultipleOrgs"

  web {
    homepage_url  = "https://argo.haste.cloud"
    redirect_uris = ["https://argo.haste.cloud/auth/callback"]
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All
      type = "Role"
    }
  }

  group_membership_claims = ["All"]
}
