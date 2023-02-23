data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "devops" {
    name = "sapi-devops"
    location = "East us"
}