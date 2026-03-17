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

variable "allowed_locations" {
  description = "Azure locations allowed for resource deployments"
  type        = list(string)
  default     = ["East US"]
}

variable "required_tags" {
  description = "Tags required on resources"
  type        = list(string)
  default     = ["project", "environment"]
}


variable "resource_group_lock_level" {
  description = "Management lock level for the resource group. Valid values: CanNotDelete, ReadOnly."
  type        = string
  default     = "CanNotDelete"

  validation {
    condition     = contains(["CanNotDelete", "ReadOnly"], var.resource_group_lock_level)
    error_message = "resource_group_lock_level must be either CanNotDelete or ReadOnly."
  }
}

variable "enable_resource_group_lock" {
  description = "Whether to apply a management lock to the resource group."
  type        = bool
  default     = true
}
