terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.49.0"
    }
  }

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


locals {
  main_tags = {
    environment = var.environment
    product     = var.product
    department  = "Cloud"
    source      = "Terraform"
    responsible = "Team"
  }
}

locals {
  keyvault_role_assignments = [
    "Key Vault Administrator", "Key Vault Secrets Officer", "Key Vault Reader", "Key Vault Secrets User"
  ]
  service_principals = [
    "${var.sp_object_id}",
    "${data.azurerm_client_config.current.object_id}"
  ]
  keyvault_role_service_principal_assignment = distinct(flatten([
    for role in local.keyvault_role_assignments : [
      for principal in local.service_principals : {
        principal = principal
        role      = role
      }
    ]
  ]))
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "base" {
  name     = "rg-${var.environment}-${var.product}-terraform"
  location = var.location

  tags = merge(local.main_tags, var.user_tags)
}

resource "azurerm_storage_account" "stg_base" {
  name                     = "stgtf${var.environment}${var.product}"
  resource_group_name      = azurerm_resource_group.base.name
  location                 = azurerm_resource_group.base.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = false

  tags = merge(local.main_tags, var.user_tags)
}

resource "azurerm_storage_container" "terraform" {
  name                 = "terraform"
  storage_account_name = azurerm_storage_account.stg_base.name

  depends_on = [
    azurerm_storage_account.stg_base
  ]
}

resource "azurerm_container_registry" "acr_devops" {
  name                = "acr${var.product}${var.environment}"
  resource_group_name = azurerm_resource_group.base.name
  location            = azurerm_resource_group.base.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = merge(local.main_tags, var.user_tags)
}

resource "azurerm_key_vault" "base_tf_keyvault" {
  name                       = "kv-${var.environment}-${var.product}-terraform"
  location                   = azurerm_resource_group.base.location
  resource_group_name        = azurerm_resource_group.base.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  enable_rbac_authorization  = true
  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  depends_on = [
    azurerm_resource_group.base,
  ]

  tags = merge(local.main_tags, var.user_tags)
}

resource "azurerm_role_assignment" "keyvault_role_assignment" {
  scope                = azurerm_key_vault.base_tf_keyvault.id
  for_each             = { for entry in local.keyvault_role_service_principal_assignment : "${entry.role}.${entry.principal}" => entry }
  role_definition_name = each.value.role
  principal_id         = each.value.principal

  depends_on = [
    azurerm_key_vault.base_tf_keyvault
  ]
}

resource "azurerm_key_vault_secret" "tf_stg_accesskey" {
  name         = "stg-terraform-access-key"
  value        = azurerm_storage_account.stg_base.primary_access_key
  key_vault_id = azurerm_key_vault.base_tf_keyvault.id

  depends_on = [
    azurerm_role_assignment.keyvault_role_assignment
  ]
}

resource "azurerm_key_vault_secret" "tf_clientId" {
  name         = "tf-client-id"
  value        = var.sp_client_id
  key_vault_id = azurerm_key_vault.base_tf_keyvault.id
  depends_on = [
    azurerm_role_assignment.keyvault_role_assignment
  ]
}

resource "azurerm_key_vault_secret" "tf_client_secret" {
  name         = "tf-client-secret"
  value        = var.sp_client_secret
  key_vault_id = azurerm_key_vault.base_tf_keyvault.id
  depends_on = [
    azurerm_role_assignment.keyvault_role_assignment
  ]
}

resource "azurerm_key_vault_secret" "tf_subscription_id" {
  name         = "tf-subscription-id"
  value        = data.azurerm_client_config.current.subscription_id
  key_vault_id = azurerm_key_vault.base_tf_keyvault.id
  depends_on = [
    azurerm_role_assignment.keyvault_role_assignment
  ]
}

resource "azurerm_key_vault_secret" "tf_tenant_id" {
  name         = "tf-tenant-id"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = azurerm_key_vault.base_tf_keyvault.id
  depends_on = [
    azurerm_role_assignment.keyvault_role_assignment
  ]
}

resource "azurerm_key_vault_secret" "acr_base_login" {
  name         = "acr-base-login"
  value        = azurerm_container_registry.acr_devops.admin_username
  key_vault_id = azurerm_key_vault.base_tf_keyvault.id
  depends_on = [
    azurerm_role_assignment.keyvault_role_assignment
  ]
}
resource "azurerm_key_vault_secret" "acr_base_password" {
  name         = "acr-base-password"
  value        = azurerm_container_registry.acr_devops.admin_password
  key_vault_id = azurerm_key_vault.base_tf_keyvault.id
  depends_on = [
    azurerm_role_assignment.keyvault_role_assignment
  ]
}
resource "azurerm_key_vault_secret" "acr_base_url" {
  name         = "acr-base-url"
  value        = azurerm_container_registry.acr_devops.login_server
  key_vault_id = azurerm_key_vault.base_tf_keyvault.id
  depends_on = [
    azurerm_role_assignment.keyvault_role_assignment
  ]
}
