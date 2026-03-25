resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

module "vnets" {
  source   = "./modules/vnets"
  for_each = local.vnets

  name          = each.key
  address_space = [each.value.address_space]
  location      = azurerm_resource_group.rg.location
  rg            = azurerm_resource_group.rg.name
}

module "vnets_peering" {
  source   = "./modules/vnet-peering"
  for_each = local.vnets

  peering_name   = "${each.key}-peer"
  rg             = azurerm_resource_group.rg.name
  vnet_name      = each.key
  remote_vnet_id = module.vnets[each.value.peered_to].vnet_id

  allow_vnet_access       = each.value.allow_virtual_network_access
  allow_forwarded_traffic = each.value.allow_forwarded_traffic
}

module "subnets" {
  depends_on = [module.vnets]
  source     = "./modules/networking"
  for_each   = local.subnets

  subnet_name      = each.key
  rg               = azurerm_resource_group.rg.name
  location         = azurerm_resource_group.rg.location
  vnet_name        = each.value.vnet
  address_prefixes = each.value.address_prefixes
}

module "virtual_machines" {
  source   = "./modules/vms"
  for_each = local.virtual_machines

  name     = each.key
  location = azurerm_resource_group.rg.location
  rg       = azurerm_resource_group.rg.name
  vm_size  = each.value.vm_size
  os_name  = "${each.key}-osdisk"
  tag      = try(each.value.tag, {})

  computer_name  = "${each.key}-vm"
  admin_username = "${each.key}-admin"
  admin_password = var.admin_password

  nic_name  = "${each.key}-nic"
  subnet_id = module.subnets["workload_logic_subnet"].subnet_id

}

module "pip" {
  source   = "./modules/pip"
  for_each = local.public_ips

  name              = each.key
  location          = azurerm_resource_group.rg.location
  rg                = azurerm_resource_group.rg.name
  allocation_method = each.value.allocation_method
  sku               = each.value.sku
}

resource "azurerm_bastion_host" "bastion-host" {
  name                = var.bastion_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"


  ip_configuration {
    name                 = "configuration"
    subnet_id            = module.subnets["AzureBastionSubnet"].subnet_id
    public_ip_address_id = module.pip["bastion-pip"].pip_id
  }
}


module "vms_inbound_nsg" {
  source   = "./modules/nsg"
  for_each = local.nsg_rules

  name           = each.key
  location       = azurerm_resource_group.rg.location
  rg             = azurerm_resource_group.rg.name
  security_rules = each.value
}

resource "azurerm_subnet_network_security_group_association" "nsg_app_assoc" {
  subnet_id                 = module.subnets["workload_logic_subnet"].subnet_id
  network_security_group_id = module.vms_inbound_nsg["nsg-app"].nsg_id
}

module "nat" {
  source = "./modules/nat"

  name         = var.nat_name
  location     = azurerm_resource_group.rg.location
  rg           = azurerm_resource_group.rg.name
  sku_name     = "Standard"
  public_ip_id = module.pip["nat_pip"].pip_id
}

resource "azurerm_subnet_nat_gateway_association" "vms_asociation" {
  subnet_id      = module.subnets["workload_logic_subnet"].subnet_id
  nat_gateway_id = module.nat.nat_id
}

resource "azurerm_role_assignment" "monitor_roles" {
  for_each = local.monitor_roles

  scope              = azurerm_resource_group.rg.id
  role_definition_id = each.value
  principal_id       = module.virtual_machines["monitor-vm"].principal_id
}

module "monitor_law" {
  source = "./modules/monitor"

  law_name             = local.law_name
  location             = azurerm_resource_group.rg.location
  rg                   = azurerm_resource_group.rg.name
  action_group_name    = local.action_group_name
  email_receiver_name  = local.email_receiver_name
  email_receiver_email = var.email_receiver_email
  metric_alert_name    = local.metric_alert_name
  vms_ids              = [for vm in module.virtual_machines : vm.vm_id]
  cpu_threshold        = var.cpu_threshold
}

module "ilb" {
  source = "./modules/ilb"

  ilb_name          = var.ilb_name
  location          = azurerm_resource_group.rg.location
  rg                = azurerm_resource_group.rg.name
  subnet_id         = module.subnets["workload_logic_subnet"].subnet_id
  backend_pool_name = var.backend_pool_name
  health_probe_name = var.vms_health_probe
  lb_rule_name      = var.vms_lb_rule
}

resource "azurerm_network_interface_backend_address_pool_association" "name" {
  for_each = local.virtual_machines

  network_interface_id    = module.virtual_machines[each.key].nic_id
  ip_configuration_name   = "${each.key}-nic-ipconfig"
  backend_address_pool_id = module.ilb.backend_pool_id
}

module "ama" {
  depends_on = [module.monitor_law]

  source   = "./modules/ama"
  for_each = local.virtual_machines

  rg       = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  ama_name = "${each.key}_ama"

  identifier_name = "${each.key}_res_id"
  vm_id           = module.virtual_machines[each.key].vm_id
  vm_principal_id = module.virtual_machines[each.key].principal_id

  law_id               = module.monitor_law.law_id
  law_name_destination = "${each.key}_law_destination"

  dcr_name             = "dcr-for-${each.key}"
  dcr_target_resource  = module.virtual_machines[each.key].vm_id
  dcr_association_name = "${each.key}-dcr-association"
}
