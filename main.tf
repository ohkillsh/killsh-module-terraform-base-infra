terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.49.0"
    }
  }

  #backend "azurerm" {
  #  
  #}
}

provider "azurerm" {
  # Configuration options
  features {
    key_vault {
      purge_soft_deleted_secrets_on_destroy = true
      recover_soft_deleted_secrets          = true
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "base" {
  name     = "rg-base-${var.product}"
  location = "eastus"
}

resource "azurerm_storage_account" "stg_base" {
  name                     = "stgbase${var.environment}${var.product}"
  resource_group_name      = azurerm_resource_group.base.name
  location                 = azurerm_resource_group.base.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = false

  tags = var.tags
}

resource "azurerm_storage_container" "terraform" {
  name                 = "terraform"
  storage_account_name = azurerm_storage_account.stg_base.name

  depends_on = [
    azurerm_storage_account.stg_base
  ]
}

resource "azurerm_container_registry" "acr_devops" {
  name                = "acr-${var.product}${var.environment}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_container_registry_scope_map" "acr_devops_scopemap" {
  name                    = "acr-${var.product}${var.environment}-scopemap"
  container_registry_name = azurerm_container_registry.acr_devops.name
  resource_group_name     = azurerm_resource_group.base.name
  actions = [
    "repositories/*"
  ]
}

resource "azurerm_container_registry_token" "acr_devops_token" {
  name                    = "acr-devops-token"
  container_registry_name = azurerm_container_registry.acr_devops.name
  resource_group_name     = azurerm_resource_group.base.name
  scope_map_id            = azurerm_container_registry_scope_map.acr_devops_scopemap.id
}

resource "azurerm_container_registry_token_password" "acr_devops_token_password" {
  container_registry_token_id = azurerm_container_registry_token.acr_base_token.id

  password1 {}
  password2 {}

}

resource "azurerm_key_vault" "base_tf_keyvault" {
  name                       = "kv-infrastructure-${var.product}${var.environment}"
  location                   = azurerm_resource_group.base.location
  resource_group_name        = azurerm_resource_group.base.name
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

resource "azurerm_key_vault_secret" "tf_stg_accesskey" {
  name         = "stg-terraform-accesskey"
  value        = azurerm_storage_account.stg_base.primary_access_key
  key_vault_id = azurerm_key_vault.base_tf_keyvault.id

  depends_on = [
    azurerm_storage_account.stg_base
  ]
}

resource "azurerm_key_vault_secret" "tf_clientId" {
  name         = "tf-clientId"
  value        = var.client_id
  key_vault_id = azurerm_key_vault.base_tf_keyvault.id
}

resource "azurerm_key_vault_secret" "tf_subscriptionId" {
  name         = "tf-subscriptionId"
  value        = data.azurerm_client_config.current.subscription_id
  key_vault_id = azurerm_key_vault.base_tf_keyvault.id
}

resource "azurerm_key_vault_secret" "tf_tenantId" {
  name         = "tf-tenantId"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = azurerm_key_vault.base_tf_keyvault.id
}

resource "azurerm_key_vault_secret" "tf_clientSecret" {
  name         = "tf-tenantId"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = azurerm_key_vault.base_tf_keyvault.id
}

resource "azurerm_key_vault_secret" "acr_base_login" {
  name         = "acr-base-login"
  value        = azurerm_container_registry_token.acr_devops_token.id
  key_vault_id = azurerm_key_vault.base_tf_keyvault.id
}
resource "azurerm_key_vault_secret" "acr-base-password" {
  name         = "acr-base-password"
  value        = azurerm_container_registry_token_password.acr_devops_token_password.password1
  key_vault_id = azurerm_key_vault.base_tf_keyvault.id
}
resource "azurerm_key_vault_secret" "acr-base-url" {
  name         = "acr-base-url"
  value        = azurerm_container_registry.acr_devops.login_server
  key_vault_id = azurerm_key_vault.base_tf_keyvault.id
}




