# keyvault
resource "azurerm_key_vault" "cluster_secrets" {
  name                = "cluster-kv-felixwie"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tenant_id = data.azuread_client_config.current.tenant_id
  sku_name  = "standard"
}

# storage
resource "azurerm_storage_account" "cluster_storage" {
  name                = "clusterstoragefw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
  }

  allow_nested_items_to_be_public = false
  default_to_oauth_authentication = true
}

# sql
resource "azuread_group" "sqladmin" {
  display_name     = "SQLAdmin"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}

resource "azuread_group_member" "current" {
  group_object_id  = azuread_group.sqladmin.object_id
  member_object_id = data.azuread_client_config.current.object_id
}

resource "azuread_group_member" "workload" {
  group_object_id  = azuread_group.sqladmin.object_id
  member_object_id = azurerm_user_assigned_identity.workload.principal_id
}

resource "azurerm_mssql_server" "sql" {
  name                = "felixwie-sql"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  version = "12.0"
  azuread_administrator {
    azuread_authentication_only = true
    object_id                   = azuread_group.sqladmin.object_id
    login_username              = "SQLAdmin"
  }
}

resource "azurerm_mssql_database" "monitoring" {
  name      = "monitoring"
  server_id = azurerm_mssql_server.sql.id

  min_capacity                = 1
  max_size_gb                 = 5
  auto_pause_delay_in_minutes = 60
  sku_name                    = "GP_S_Gen5_1"
  zone_redundant              = false
  storage_account_type        = "Local"
}
