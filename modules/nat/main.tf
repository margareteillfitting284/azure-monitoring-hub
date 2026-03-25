resource "azurerm_nat_gateway" "nat" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg
  sku_name            = var.sku_name 
}

resource "azurerm_nat_gateway_public_ip_association" "nat_pip" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = var.public_ip_id
}
