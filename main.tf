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

# ARM deployment of a resource with 
# managed identity and with output values
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

# Resource that references the output of the ARM deployment.
# This is what makes "terraform plan" fail. 
resource "azurerm_role_assignment" "file_st_role_assignment" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Reader"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.arm_deployment.output_content).principalId.value
}
