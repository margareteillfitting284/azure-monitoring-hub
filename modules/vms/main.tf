resource "azurerm_network_interface" "vm_nic" {
  name                = var.nic_name
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "${var.nic_name}-ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                         = var.name
  location                     = var.location
  resource_group_name          = var.rg
  network_interface_ids        = [azurerm_network_interface.vm_nic.id]
  primary_network_interface_id = azurerm_network_interface.vm_nic.id
  vm_size                      = var.vm_size 

  identity {
    type = "SystemAssigned"
  }
  
  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = var.os_name
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {                        
    computer_name  = var.computer_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = var.tag
}
