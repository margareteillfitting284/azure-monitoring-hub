resource "azurerm_virtual_machine_extension" "ama" {
  name                       = var.ama_name 
  virtual_machine_id         = var.vm_id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    authentication = {
      managed_identity = {
        identifier-name  = var.identifier_name 
        identifier-value = var.vm_principal_id
      }
    }
  })
}

resource "azurerm_monitor_data_collection_rule" "dcr_vm1" {
  name                = var.dcr_name 
  resource_group_name = var.rg
  location            = var.location

  destinations {
    log_analytics {
      workspace_resource_id = var.law_id 
      name                  = var.law_name_destination 
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog", "Microsoft-Perf"]
    destinations = [var.law_name_destination]
  }

  data_sources {
    syslog {
      name           = "syslog"
      facility_names = ["*"]
      log_levels     = ["*"]
      streams        = ["Microsoft-Syslog"]
    }

    performance_counter {
      name                          = "performance_counters"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor(*)\\% Processor Time",
        "\\Memory\\Available Bytes",
        "\\LogicalDisk(*)\\% Free Space",
        "\\Network Interface(*)\\Bytes Total/sec"
      ]
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "dcr_assoc_vm1" {
  name                    = var.dcr_association_name
  target_resource_id      = var.dcr_target_resource 
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr_vm1.id
}