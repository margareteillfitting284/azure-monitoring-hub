
resource "azurerm_public_ip" "pip" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg
  allocation_method   = var.allocation_method
  sku                 = var.sku
}