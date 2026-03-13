output "resource_group_name" {
  description = "Created resource group name"
  value       = azurerm_resource_group.devops_rg.name
}

output "resource_group_id" {
  description = "Created resource group id"
  value       = azurerm_resource_group.devops_rg.id
}
