terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}


provider "azurerm" {
   
  features {}
  # skip_provider_registration = true
}

# getting current resource group as playground permissions are limited
data "azurerm_resource_group" "existing" {
  name = var.rg_name 
}

# Creating a virtual network 
resource "azurerm_virtual_network" "vn-tkxelassign2" {
  name                = "network-tkxelassign2"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet-tkxelassign2" {
  name                 = "subnet-tkxelassign2"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.vn-tkxelassign2.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "terraform_public_ip" {
  name                = "public-ip-tkxelassign2"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic-tkxelassign2" {
  name                = "tkxelassign2-nic"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "tkxelassign2-IP-configuration1"
    subnet_id                     = azurerm_subnet.subnet-tkxelassign2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.terraform_public_ip.id
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "terraform_nsg" {
  name                = "terraform-nsg"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Connect the security group
resource "azurerm_network_interface_security_group_association" "nsg_association_terraform" {
  network_interface_id      = azurerm_network_interface.nic-tkxelassign2.id
  network_security_group_id = azurerm_network_security_group.terraform_nsg.id
}

resource "azurerm_virtual_machine" "vm-tkxelassign2" {
  name                  = "vm-tkxelassign2"
  location              = data.azurerm_resource_group.existing.location
  resource_group_name   = data.azurerm_resource_group.existing.name
  network_interface_ids = [azurerm_network_interface.nic-tkxelassign2.id]
  vm_size               = "standard_b1s"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "vm-tkxelassign2"        # Name of the VM inside the OS
    admin_username = var.adm_user         # Admin username
    admin_password = var.adm_pass  # Password for the admin user (optional if using SSH keys)
  }
    
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
        key_data = file(var.keydata) 
        path = "/home/mahad/.ssh/authorized_keys"
    }
  }
  tags = {
    environment = var.environment_name
  }
}