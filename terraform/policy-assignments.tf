data "azurerm_user_assigned_identity" "update_management_user_assigned_identity" {
  name                = var.user_assigned_identity_name
  resource_group_name = var.user_assigned_identity_rg
}

# create Policy Assignment for default maintenance configuration at subscription level
resource "azurerm_subscription_policy_assignment" "maintenance_configuration_assignment_default" {
  name                 = "maintenance_configuration_assignment_default"
  subscription_id = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.enroll_arc_servers_to_update_management_center.id
  description          = "Policy Assignment for Selective enrollment of Arc machines to default Maintenance configuration"
  display_name         = "Enrollment to default Maintenance Configuration"
  location             = var.policy_assignment_location
  identity {
    type = "UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.update_management_user_assigned_identity.id
    ]
  }

  non_compliance_message {
    content = "Arc Server is not associated with a Maintenance Configuration"
  }

  parameters = jsonencode({
    
    tagValues = {
      value = [
      {
       key = "updatePolicy" 
       value = "Default"
       },
        { 
        key = "updateSchedule" 
        value = "Default"
        }

    ]},
    tagOperator = {
      value = "All"
    },
    maintenanceConfigurationResourceId = {
      value = azurerm_maintenance_configuration.arc_server_maintenance_configuration_default.id
    },
    maintenanceConfigurationAssignmentName = {
      value = "mainconfassignment"
    }

  })
}

# create Policy Assignment for weekend maintenance configuration at subscription level
resource "azurerm_subscription_policy_assignment" "maintenance_configuration_assignment_weekend" {
  name                 = "maintenance_configuration_assignment_weekend"
  subscription_id = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.enroll_arc_servers_to_update_management_center.id
  description          = "Policy Assignment for Selective enrollment of Arc machines to weekend Maintenance configuration"
  display_name         = "Enrollment to weekend Maintenance Configuration"
  location             = var.policy_assignment_location
  identity {
    type = "UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.update_management_user_assigned_identity.id
    ]
  }

  non_compliance_message {
    content = "Arc Server is not associated with a Maintenance Configuration"
  }

  parameters = jsonencode({
    
    tagValues = {
      value = [
      {
       key = "updatePolicy" 
       value = "Default"
       },
        { 
        key = "updateSchedule" 
        value = "Weekend-Only"
        }

    ]},
    tagOperator = {
      value = "All"
    },
    maintenanceConfigurationResourceId = {
      value = azurerm_maintenance_configuration.arc_server_maintenance_configuration_weekend.id
    },
    maintenanceConfigurationAssignmentName = {
      value = "mainconfassignment"
    }

  })
}

# Create a role assignment at subscription level for patch management
resource "azurerm_role_assignment" "policy_role_assignment_subscription" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Azure Connected Machine Resource Administrator"
  principal_id         = data.azurerm_user_assigned_identity.update_management_user_assigned_identity.principal_id
}

# Assign User Assigned Managed Identity permissions on the two Maintenance Configurations
resource "azurerm_role_assignment" "role_assignment_maintenance_configuration_default" {
  scope                = azurerm_maintenance_configuration.arc_server_maintenance_configuration_default.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.update_management_user_assigned_identity.principal_id
}

resource "azurerm_role_assignment" "role_assignment_maintenance_configuration_weekend" {
  scope                = azurerm_maintenance_configuration.arc_server_maintenance_configuration_weekend.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.update_management_user_assigned_identity.principal_id
}





