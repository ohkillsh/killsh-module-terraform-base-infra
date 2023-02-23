data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "devops" {
    name = "${var.product}-devops"
    location = "eastus"
}