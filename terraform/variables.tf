variable "maintenance_configuration_resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Maintenance Configuration."
}

variable "maintenance_configuration_resource_location" {
  type        = string
  description = "The location of t the Azure Policy Assignment."

}

variable "user_assigned_identity_name" {
  description = "The ID of the User Assigned Identity"
  type        = string
}

variable "user_assigned_identity_rg" {
  description = "The resource group where the User Assigned Identity is located"
  type        = string
}

variable "policy_assignment_location" {
  description = "The location of the Azure Policy Assignment"
  type        = string
}


