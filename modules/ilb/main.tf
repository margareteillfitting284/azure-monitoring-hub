resource "azurerm_lb" "ilb" {
  name                = var.ilb_name
  location            = var.location
  resource_group_name = var.rg
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "workload-privated"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.10"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.ilb.id
  name            = var.backend_pool_name
}

resource "azurerm_lb_probe" "health_probe" {
  loadbalancer_id = azurerm_lb.ilb.id
  name            = var.health_probe_name 
  protocol        = "Tcp"
  port            = 22
}

resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id                = azurerm_lb.ilb.id
  name                           = var.lb_rule_name
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  disable_outbound_snat          = true
  frontend_ip_configuration_name = azurerm_lb.ilb.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.health_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
}