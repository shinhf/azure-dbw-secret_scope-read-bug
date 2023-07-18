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
  custom_parameters {
    no_public_ip                                         = false
    virtual_network_id                                   = azurerm_virtual_network.main_vnet.id
    public_subnet_name                                   = azurerm_subnet.dbw_subnet_public.name
    private_subnet_name                                  = azurerm_subnet.dbw_subnet_private.name  
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.dbw_subnet_public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.dbw_subnet_private.id  
  }
}

resource "azurerm_network_security_group" "dbw_nsg" {
  name                = azurecaf_name.caf_nsg_dbw.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "dbw_subnet_private" {
  name                 = azurecaf_name.caf_subnet_dbw_private.result
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = [var.list_of_subnet_cidr[3].ip_address_range]

  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "dbw_subnet_private" {
  subnet_id                 = azurerm_subnet.dbw_subnet_private.id
  network_security_group_id = azurerm_network_security_group.dbw_nsg.id
}

resource "azurerm_subnet" "dbw_subnet_public" {
  name                 = azurecaf_name.caf_subnet_dbw_public.result
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = [var.list_of_subnet_cidr[2].ip_address_range]

  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "dbw_subnet_public" {
  subnet_id                 = azurerm_subnet.dbw_subnet_public.id
  network_security_group_id = azurerm_network_security_group.dbw_nsg.id
}



#######

resource "azurecaf_name" "caf_subnet_dbw_public" {
  resource_type = "azurerm_subnet"
  name          = var.environment
  random_length = 4
  clean_input   = true
  suffixes        = ["dbw-public"]
}

resource "azurecaf_name" "caf_subnet_dbw_private" {
  resource_type = "azurerm_subnet"
  name          = var.environment
  random_length = 4
  clean_input   = true
  suffixes        = ["dbw-private"]
}

resource "azurecaf_name" "caf_nsg_dbw" {
  resource_type = "azurerm_network_security_group"
  name          = var.environment
  random_length = 4
  clean_input   = true
  suffixes        = ["dbw"]
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

  depends_on = [ azurerm_databricks_workspace.databricks_workspace ]
}