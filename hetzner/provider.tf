terraform {
  backend "azurerm" {
    storage_account_name = "fwdatastore"
    container_name       = "terraform"
    key                  = "hetzer_state.tfstate"
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.35.2"
    }
  }
}

provider "hcloud" {
  token = var.token
}
