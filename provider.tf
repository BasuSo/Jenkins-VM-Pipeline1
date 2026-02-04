# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
  
  subscription_id = "6c4417f5-9d0f-41a5-97a9-678ee83cbefa"
  tenant_id = "f544d041-6da2-484d-bf90-f7d3afd7054b"
}