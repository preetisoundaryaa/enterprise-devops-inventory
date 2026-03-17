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


resource "azurerm_policy_definition" "allowed_locations" {
  name         = "allowed-locations-enterprise-devops-inventory"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed Azure locations"
  description  = "Restrict resource creation to approved Azure regions."

  metadata = jsonencode({
    category = "General"
  })

  parameters = jsonencode({
    listOfAllowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed locations"
        description = "The list of allowed Azure locations for resource deployments."
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "location"
          notIn = "[parameters('listOfAllowedLocations')]"
        },
        {
          field  = "type"
          notEquals = "Microsoft.AzureActiveDirectory/b2cDirectories"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations-assignment"
  resource_group_id    = azurerm_resource_group.devops_rg.id
  policy_definition_id = azurerm_policy_definition.allowed_locations.id
  display_name         = "Allowed locations assignment"
  description          = "Enforce deployments only in approved locations."

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.allowed_locations
    }
  })
}

resource "azurerm_policy_definition" "required_tags" {
  name         = "required-tags-enterprise-devops-inventory"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Required tags for resources"
  description  = "Ensure required tags are set on Azure resources."

  metadata = jsonencode({
    category = "Tags"
  })

  policy_rule = jsonencode({
    if = {
      anyOf = [for tag in var.required_tags : {
        field  = "tags['${tag}']"
        exists = "false"
      }]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "required_tags" {
  name                 = "required-tags-assignment"
  resource_group_id    = azurerm_resource_group.devops_rg.id
  policy_definition_id = azurerm_policy_definition.required_tags.id
  display_name         = "Required tags assignment"
  description          = "Require baseline governance tags on resources."
}

resource "azurerm_policy_definition" "deny_public_ip" {
  name         = "deny-public-ip-enterprise-devops-inventory"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny public IP creation"
  description  = "Block creation of Azure Public IP resources in this scope."

  metadata = jsonencode({
    category = "Network"
  })

  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Network/publicIPAddresses"
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "deny_public_ip" {
  name                 = "deny-public-ip-assignment"
  resource_group_id    = azurerm_resource_group.devops_rg.id
  policy_definition_id = azurerm_policy_definition.deny_public_ip.id
  display_name         = "Deny public IP assignment"
  description          = "Prevent accidental exposure by disallowing public IPs."
}


resource "azurerm_management_lock" "resource_group_lock" {
  count      = var.enable_resource_group_lock ? 1 : 0
  name       = "${azurerm_resource_group.devops_rg.name}-lock"
  scope      = azurerm_resource_group.devops_rg.id
  lock_level = var.resource_group_lock_level
  notes      = "Basic protection lock managed by Terraform."
}
