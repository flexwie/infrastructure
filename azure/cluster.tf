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

# resource "azurerm_kubernetes_cluster_node_pool" "pool" {
#   name                  = "user"
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.cluster.id
#   vm_size               = "standard_b2s"
#   enable_auto_scaling   = true
#   max_count             = 2
#   min_count             = 0
#   node_count            = 0
# }

data "azurerm_kubernetes_cluster" "cluster_data" {
  name                = azurerm_kubernetes_cluster.cluster.name
  resource_group_name = azurerm_resource_group.rg.name
}

# create domain pointing to the cluster
resource "azurerm_dns_zone" "dns" {
  name                = var.dns_name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_a_record" "routing" {
  name                = "*"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 60
  records             = ["20.113.41.131"]
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

