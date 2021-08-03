provider "azurerm" {
  skip_provider_registration = true
  features {}
}

locals {
  unique_suffix = "adjkh1213"
  location      = "westeurope"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.unique_suffix}"
  location = local.location
}

# Storage account is only used to demonstrate
# how `azurerm_role_assignment` fails in the future.
resource "azurerm_storage_account" "storage" {
  name                     = "storage${local.unique_suffix}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# ARM deployment of a resource without 
# managed identity and without output values
resource "azurerm_resource_group_template_deployment" "arm_deployment" {
  name                = "deployment-${local.unique_suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "logic-app-name" = {
      value = "logic-app-name"
    }
  })
  template_content = file("logicapp.json")
}
