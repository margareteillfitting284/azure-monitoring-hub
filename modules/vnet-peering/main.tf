resource "azurerm_virtual_network_peering" "security_to_workload" {
  name                      = var.peering_name
  resource_group_name       = var.rg
  virtual_network_name      = var.vnet_name
  remote_virtual_network_id = var.remote_vnet_id

  allow_virtual_network_access = var.allow_vnet_access
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
