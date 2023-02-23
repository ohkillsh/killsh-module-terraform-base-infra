resource "azurerm_key_vault" "base-tf-keyvault" {
  name                       = "${var.product}${var.environment}-tf-keyvault"
  location                   = azurerm_resource_group.devops.location
  resource_group_name        = azurerm_resource_group.devops.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "GetRotationPolicy", "SetRotationPolicy", "Rotate"
    ]

    secret_permissions = [
      "Set",
      "List",
      "Get",
      "Delete",
      "Purge",
      "Recover",
      "Backup",
      "Restore"
    ]
  }

  lifecycle {
    ignore_changes = [
      access_policy,
    ]
  }

  depends_on = [
    azurerm_resource_group.devops
  ]
}
 
resource "azurerm_key_vault_secret" "tf-stg-accesskey" {
  name         = "stg-terraform-accesskey"
  value        = azurerm_storage_account.stg-base.primary_access_key
  key_vault_id = azurerm_key_vault.base-tf-keyvault.id

  depends_on = [
    azurerm_storage_account.stg-base
  ]
}

resource "azurerm_key_vault_secret" "tf-clientId" {
  name         = "tf-clientId"
  value        = var.client_id
  key_vault_id = azurerm_key_vault.base-tf-keyvault.id
}

resource "azurerm_key_vault_secret" "tf-subscriptionId" {
  name         = "tf-subscriptionId"
  value        = data.azurerm_client_config.current.subscription_id
  key_vault_id = azurerm_key_vault.base-tf-keyvault.id
}
 
resource "azurerm_key_vault_secret" "tf-tenantId" {
  name         = "tf-tenantId"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = azurerm_key_vault.base-tf-keyvault.id
}

resource "azurerm_key_vault_secret" "tf-clientSecret" {
  name         = "tf-tenantId"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = azurerm_key_vault.base-tf-keyvault.id
}
 
# # TODO: Create Secrets for Docker Container tf-docker-login
# # TODO: Create Secrets for Docker Container tf-docker-password
# TODO: Create Secrets for Docker Container tf-docker-registry-url
