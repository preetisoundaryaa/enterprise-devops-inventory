terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "devops_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    project     = "enterprise-devops-inventory"
    environment = var.environment
  }
}
