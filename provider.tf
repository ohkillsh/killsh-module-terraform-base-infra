terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.44.1"
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