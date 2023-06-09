data "azurerm_client_config" "current" {}

data "azuread_service_principal" "sp_devops_automation" {
  application_id = var.sp_client_id
}
