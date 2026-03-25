resource "azurerm_log_analytics_workspace" "example" {
  name                = var.law_name
  location            = var.location
  resource_group_name = var.rg
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_action_group" "email" {
  name                = var.action_group_name
  resource_group_name = var.rg
  short_name          = "p0action"

  email_receiver {
    name          = var.email_receiver_name 
    email_address = var.email_receiver_email 
  }
}

resource "azurerm_monitor_metric_alert" "example" {
  name                = var.metric_alert_name
  resource_group_name = var.rg
  scopes              = var.vms_ids
  severity            = 2

  target_resource_type = "Microsoft.Compute/virtualMachines"
  target_resource_location = "eastus2"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      =  "Percentage CPU"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.cpu_threshold
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.email.id
  }
}