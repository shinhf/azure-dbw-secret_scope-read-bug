resource "azurecaf_name" "caf_databricks_workspace" {
  resource_type = "azurerm_databricks_workspace"
  name          = var.environment
  random_length = 4
  clean_input   = true
}

resource "azurerm_databricks_workspace" "databricks_workspace" {
  name                = azurecaf_name.caf_databricks_workspace.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "premium"

  managed_resource_group_name = "rg-${azurecaf_name.caf_databricks_workspace.result}"

  customer_managed_key_enabled = true

  tags = {
    env     = var.environment
    version = var.environment_version
  }
}

#########

resource "azurerm_role_assignment" "dbw_kv" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azuread_service_principal.databricks_workspace.object_id
}



resource "databricks_secret_scope" "kv" {
  name = "keyvault-${var.environment}"
  # depends_on = [ azurerm_role_assignment.dbw_kv ]
  keyvault_metadata {
    resource_id = data.azurerm_key_vault.kv.id
    dns_name    = data.azurerm_key_vault.kv.vault_uri
  }
}