resource "azurerm_policy_definition" "enroll_arc_servers_to_update_management_center" {
  name         = "enroll_arc_servers_to_update_management_center"
  display_name = "Selective enrollment of Arc enabled Servers for Update Management Center"
  description  = "Selective enrollment of Arc enabled Servers for Update Management Center"
  policy_type  = "Custom"
  mode         = "Indexed"
  metadata     = <<METADATA
    {
    "category": "Update Management Center"
    }

METADATA 

  policy_rule = <<POLICY_RULE
  {
  "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.HybridCompute/machines"
        },
        {
          "anyOf": [
            {
              "value": "[empty(parameters('tagValues'))]",
              "equals": true
            },
            {
              "allOf": [
                {
                  "value": "[empty(field('tags'))]",
                  "equals": false
                },
                {
                  "value": "[parameters('tagOperator')]",
                  "equals": "Any"
                },
                {
                  "count": {
                    "value": "[parameters('tagValues')]",
                    "name": "tagKvp",
                    "where": {
                      "value": "[length(intersection(createObject(current('tagKvp').key, current('tagKvp').value), field('tags')))]",
                      "greater": 0
                    } 
                  },
                  "greater": 0
                }
              ]
            },
            {
              "allOf": [
                {
                  "value": "[empty(field('tags'))]",
                  "equals": false
                },
                {
                  "value": "[parameters('tagOperator')]",
                  "equals": "All"
                },
                {
                  "count": {
                    "value": "[parameters('tagValues')]",
                    "name": "tagKvp",
                    "where": {
                      "value": "[length(intersection(createObject(current('tagKvp').key, current('tagKvp').value), field('tags')))]",
                      "greater": 0
                    }
                  },
                  "equals": "[length(parameters('tagValues'))]"
                }
              ]
            }
          ]
        }
      ]
    },
    "then": {
      "effect": "deployIfNotExists",
      "details": {
        "type": "Microsoft.Maintenance/configurationAssignments",
        "existenceCondition": {
          "allOf": [
            {
              "field": "Microsoft.Maintenance/configurationAssignments/maintenanceConfigurationId",
              "equals": "[parameters('maintenanceConfigurationResourceId')]"
            }
          ]
        },
        "deployment": {
          "properties": {
            "mode": "incremental",
            "template": {
              "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
              "contentVersion": "1.0.0.0",
              "parameters": {
                "maintenanceConfigurationResourceId": {
                  "type": "String"
                },
                "maintenanceConfigurationAssignmentName": {
                  "type": "String"
                },
                "arcServerResourceId": {
                  "type": "String"
                }
              },
              "resources": [
                {
                  "type": "Microsoft.Maintenance/configurationAssignments",
                  "apiVersion": "2022-11-01-preview",
                  "name": "[parameters('maintenanceConfigurationAssignmentName')]",
                  "location": "[resourceGroup().location]",
                  "scope": "[parameters('arcServerResourceId')]",
                  "properties": {
                    "maintenanceConfigurationId": "[parameters('maintenanceConfigurationResourceId')]",
                    "resourceId": "[parameters('arcServerResourceId')]"
                  }
                }
              ]
            },
            "parameters": {
              "maintenanceConfigurationResourceId": {
                "value": "[parameters('maintenanceConfigurationResourceId')]"
              },
              "maintenanceConfigurationAssignmentName": {
                "value": "[parameters('maintenanceConfigurationAssignmentName')]"
              },
              "arcServerResourceId": {
                "value": "[field('id')]"
              }
            }
          }
        },
        "roleDefinitionIds": [
          "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
        ]
      }
    }
 }
POLICY_RULE

  parameters = <<PARAMETERS
  {
    "tagValues": {
    "type": "Array",
    "metadata": {
        "displayName": "Tags on Arc enabled Servers",
        "description": "The list of tags that need to matched for getting the target Arc Enabled Servers (case sensitive). Example: [ {\"key\": \"tagKey1\", \"value\": \"value1\"}, {\"key\": \"tagKey2\", \"value\": \"value2\"}]."
    },
    "defaultValue": []
    },
    "tagOperator": {
        "type": "String",
        "metadata": {
            "displayName": "Tags operator",
            "description": "Matching condition for resource tags"
        },
        "allowedValues": [
            "All",
            "Any"
        ],
        "defaultValue": "Any"
    },
     "maintenanceConfigurationResourceId": {
      "type": "String",
      "metadata": {
        "displayName": "The Maintenance configuration Resource Id to be associated with the Arc servers",
        "description": "The Maintenance configuration Resource Id to be associated with the Arc servers"
      }
    },
    "maintenanceConfigurationAssignmentName": {
      "type": "String",
      "metadata": {
        "displayName": "Configurationn Assignment Name",
        "description": "Configurationn Assignment Name"
      }
    }
  }
PARAMETERS
}