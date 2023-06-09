locals {
  main_tags = {
    environment = var.environment
    product     = var.product
    department  = "TBD"
    source      = "Terraform"
    responsible = "Team"
  }
}

locals {
  keyvault_role_assignments = [
    "Key Vault Administrator"
  ]
  service_principals = [
    "${data.azuread_service_principal.sp_devops_automation.display_name}",
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
