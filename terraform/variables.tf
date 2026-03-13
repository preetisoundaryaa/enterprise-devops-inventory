variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "rg-enterprise-devops-inventory"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
