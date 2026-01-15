resource "azurerm_virtual_network" "vnet" {
    name = "datacorp-vnet"
    resource_group_name = var.resource_group_name
    location = var.location
    address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
    name = "internal-subnet"
    resource_group_name = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic" {
    name = "datacorp-nic"
    location = var.location
    resource_group_name = var.resource_group_name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_linux_virtual_machine" "vm" {
    name = "datacorp-vm"
    resource_group_name = var.resource_group_name
    location = var.location
    size = "Standard_B1s" 
    admin_username = "azureuser"

    network_interface_ids = [
        azurerm_network_interface.nic.id,
    ]
    disable_password_authentication = true

    admin_ssh_key {
        username = "azureuser"
        public_key = var.public_key
    }

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" # Disque standard (pas cher)
  }

    source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

