terraform {
  backend "azurerm" {
    resource_group_name  = "felixwie"
    storage_account_name = "fwdatastore"
    container_name       = "terraform"
    key                  = "cluster.tfstate"
  }
}
