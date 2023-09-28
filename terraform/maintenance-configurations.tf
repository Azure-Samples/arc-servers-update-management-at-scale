resource "azurerm_maintenance_configuration" "arc_server_maintenance_configuration_default" {
  name                     = "mc_arc_default"
  resource_group_name      = var.maintenance_configuration_resource_group_name
  location                 = var.maintenance_configuration_resource_location
  scope                    = "InGuestPatch"
  visibility               = "Custom"
  in_guest_user_patch_mode = "User"
  window {
    duration = "02:00"
    start_date_time = "2023-10-10 10:00"
    time_zone       = "UTC"
    recur_every     = "3Day"
  }
  install_patches {
    windows {
      classifications_to_include = ["Critical", "Security", "UpdateRollup"]
    }
    linux {
      classifications_to_include = ["Critical", "Security", "Other"]
    }
    reboot = "IfRequired"
  }

}

resource "azurerm_maintenance_configuration" "arc_server_maintenance_configuration_weekend" {
  name                     = "mc_arc_weekend"
  resource_group_name      = var.maintenance_configuration_resource_group_name
  location                 = var.maintenance_configuration_resource_location
  scope                    = "InGuestPatch"
  visibility               = "Custom"
  in_guest_user_patch_mode = "User"
  window {
    duration = "02:00"
    start_date_time = "2023-10-15 10:00" #Weekend
    time_zone       = "UTC"
    recur_every     = "7Day"
  }
  install_patches {
    windows {
      classifications_to_include = ["Critical", "Security", "UpdateRollup"]
    }
    linux {
      classifications_to_include = ["Critical", "Security", "Other"]
    }
    reboot = "IfRequired"
  }

}
