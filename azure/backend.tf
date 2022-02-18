terraform {
  backend "azurerm" {
    resource_group_name  = "devops"
    storage_account_name = "felixwiestate"
    container_name       = "terraform"
    key                  = "cluster.tfstate"
  }
}
