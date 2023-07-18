# Initialize the Azure environment

# Set the terraform required version, and Configure the Azure Provider
terraform {
  required_version = ">= v1.1.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.64.0"
    }

    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.11"
    }

    databricks = {
      source  = "databricks/databricks"
      version = "1.21.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  subscription_id = var.subscription_id
}

provider "azurecaf" {
}

provider "databricks" {
  host                        = azurerm_databricks_workspace.databricks_workspace.workspace_url
}

data "azurerm_client_config" "current" {}


data "azurerm_key_vault" "kv" {
  name                = azurerm_key_vault.kv.name
  resource_group_name = azurerm_resource_group.rg.name
}

data "azuread_service_principal" "databricks_workspace" {
  display_name = "AzureDatabricks"
}