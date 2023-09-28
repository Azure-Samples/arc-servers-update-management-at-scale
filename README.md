# Update Management for Azure Arc Servers at scale

This repository contains sample Terraform code for selectively enrolling Arc Servers into the Azure Update Management Center. It demonstrates how Arc server resource tags can be leveraged to associate Arc Servers with different maintenance schedules. A single Azure Policy definition is utilized, with a policy assignment for each maintenance schedule.

## Overview

The schematic representation below explains the solution, considering a scenario requiring two distinct maintenance schedules: a default schedule and a weekend-only schedule
![Overview](./docs/images/update-management-arc-servers-scale.svg)

## Resources created by terraform

* [Policy Definition](./terraform/policy-definition.tf): This custom policy definition identifies Arc Servers (Based on associated tags) which are not associated with the required Maintenance configuration, and for those Arc Servers, it creates an association via a Maintenance Configuration Assignment. This registers the Arc server for update management, where the schedule is described in the associated maintenance configuration. The Policy needs to be provided with the following parameter values during assignment:
  * tagValues: The tag key value pair values which need to exist on the Arc server to be picked up by the policy. These need to be provided in the format below (From  [Policy Assignment - Default Schedule](./terraform/policy-assignments.tf#L27)) 
    ```
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

    ]}
    ```
  * tagOperator: The values can either be "All" or "Any". If all is specified then all the tags need to exist on the Arc Server to be selected by the policy
  * maintenanceConfigurationResourceId: The resource Id of the maintenance configuration the Arc Servers should be associated to
* Maintenance configurations: are created in the specified resource group. In the current setup two sample maintenance configurations have been created having different schedules, a default schedule, and a weekend only schedule. Any number of such configurations can be created (with required schedules), and the Arc Server tags for which a Arc server should be associated with a particular maintenance configuration can be set when creating policy assignments
  * [Maintenance Configuration - Default Schedule](./terraform/maintenance-configurations.tf#L1)
  * [Maintenance Configuration - Weekend Only Schedule](./terraform/maintenance-configurations.tf#L26)
* [Policy Assignments](./terraform/policy-assignments.tf): 
  * [Policy Assignment - Default](./terraform/policy-assignments.tf#L6): This subscription policy assignment associates Arc Servers with the 2 Tags < updatePolicy=Default and updateSchedule=Default >, with Maintenance Configuration - Default
  * [Policy Assignment - Weekend Only](./terraform/policy-assignments.tf#L52): This resource group policy assignment associates Arc Servers with the 2 Tags <updatePolicy=Default and updateSchedule=Weekend-Only>, with Maintenance Configuration - Weekend Only
* [Role Assignments](./terraform/policy-assignments.tfs#L99): For the policy to work as expected, after it has been assigned to a subscription, the associated user assigned managed identity is given following permissions via role assignments
  * Azure Connected Machine Resource Administrator on the subscription
  * Contributor permission on the 2 created Maintenance Configurations

### Terraform Variables
* maintenance_configuration_resource_group_name: The resource group where the maintenance configurations will be created
* maintenance_configuration_resource_location: The resource location where the maintenance configuration will be created
* user_assigned_identity_name: The name of the existing user assigned managed identity
* user_assigned_identity_rg: The resource group name where the user assigned managed identity exists
* policy_assignment_location: The location to be associated with the policy assignment

## Getting Started

### Prerequisites

- Terraform Should be installed
- Azure subscription 
- Azure CLI should be installed, and you should be logged in to Azure using `az login` command

### Installation

- Clone the repository `git clone https://github.com/Azure-Samples/arc-servers-update-management-at-scale.git`
- cd into the terraform directory `cd terraform`
- Add the values of variables in the [dev.auto.tfvars](./terraform/dev.auto.tfvars) file
- Run `terraform init`
- Run `terraform plan -out plan.out`
- Run `terraform apply plan.out`

## Associating Arc Servers with Maintainance Schedules via resource tags

The sample script [arc-server-registration-with-tags.sh](./scripts/arc-server-registration-with-tags.sh#L44) demonstrates how required tags can be added to Arc Servers while registering them with Azure Arc.

