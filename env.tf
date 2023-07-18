resource "azurecaf_name" "caf_rg" {
  resource_type = "azurerm_resource_group"
  name          = var.environment
  random_length = 4
  clean_input   = true
}

resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.caf_rg.result
  location = var.location

  tags = {
    env     = var.environment
    version = var.environment_version
  }
}

resource "azurecaf_name" "caf_kv" {
  resource_type = "azurerm_key_vault"
  name          = var.environment
  random_length = 4
  clean_input   = true
}

resource "azurerm_key_vault" "kv" {
  name                        = azurecaf_name.caf_kv.result
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  enable_rbac_authorization   = true

  sku_name = var.key_vault_sku

  tags = {
    env     = var.environment
    version = var.environment_version
  }
}

resource "azurecaf_name" "caf_vnet" {
  resource_type = "azurerm_virtual_network"
  name          = var.environment
  random_length = 4
  clean_input   = true
}

resource "azurerm_virtual_network" "main_vnet" {
  name                = azurecaf_name.caf_vnet.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}
