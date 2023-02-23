resource "azurerm_storage_account" "stg-base" {
  name                     = "stg${var.environment}${var.product}devops"
  resource_group_name      = azurerm_resource_group.devops.name
  location                 = azurerm_resource_group.devops.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = false
}

resource "azurerm_storage_container" "terraform" {
  name                 = "terraform"
  storage_account_name = azurerm_storage_account.stg-base.name

  depends_on = [
    azurerm_storage_account.stg-base
  ]
}