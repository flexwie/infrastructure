provider "azurerm" {
  features {}
}

data "azuread_client_config" "current" {}
data "azurerm_client_config" "curretn" {}

locals {
  workload_namespace = "kube-system"
  workload_sa        = "workload_sa"
}

resource "azurerm_resource_group" "rg" {
  name     = "cluster"
  location = "westeurope"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "cluster-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "cluster-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.1.0.0/22"]
  virtual_network_name = azurerm_virtual_network.vnet.name
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.Sql"]
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "k8s"

  automatic_channel_upgrade = "stable"
  node_resource_group       = "${azurerm_resource_group.rg.name}-nodes"
  sku_tier                  = "Free"

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = [data.azuread_client_config.current.object_id]
    azure_rbac_enabled     = true
  }

  default_node_pool {
    name            = "system"
    node_count      = 1
    vm_size         = "standard_b2s"
    vnet_subnet_id  = azurerm_subnet.subnet.id
    os_disk_size_gb = 32
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "basic"
  }

  storage_profile {
    blob_driver_enabled = true
    file_driver_enabled = true
  }
}

# identity
resource "azurerm_user_assigned_identity" "identity" {
  name                = "cluster_identity"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_role_assignment" "dns_role" {
  scope                = azurerm_dns_zone.dns.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}

resource "azurerm_user_assigned_identity" "workload" {
  name                = "workload-identity"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# resource "azurerm_role_assignment" "rg_list_role" {
#   scope              = azurerm_resource_group.rg.id
#   role_definition_id = "Reader"
#   principal_id       = azurerm_user_assigned_identity.workload.principal_id
# }

resource "azurerm_federated_identity_credential" "workload-fic" {
  name                = "workload-fic"
  resource_group_name = azurerm_resource_group.rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.cluster.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.workload.id
  subject             = "system:serviceaccount:authtest:wlsa"
}

# create domain pointing to the cluster
resource "azurerm_dns_zone" "dns" {
  name                = var.dns_name
  resource_group_name = azurerm_resource_group.rg.name
}

## Update local kube config
resource "local_file" "kubeconfig" {
  depends_on = [
    azurerm_kubernetes_cluster.cluster
  ]
  filename = "kubeconfig"
  content  = azurerm_kubernetes_cluster.cluster.kube_config_raw

  provisioner "local-exec" {
    command = "mv kubeconfig ~/.kube/config"
  }
}

