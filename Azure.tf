# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
#created the backend state and stored the terraform.tfstate file in storage account and the name of container is vizcontainer 
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name   = "newrg"
    storage_account_name  = "stgactname"
    container_name        = "vizcontainer"
    key                   = "terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group and the name is "newrg".and located the resource group in central india.in this resource group a vm is created.
# Resource group allows us to create all related resources in a single folder-like structure.
resource "azurerm_resource_group" "newrg" {
  name     = "newrg"
  location = "centralindia"
}

# created the storage account for using to store the terraform.tfstate file in remote state.and the name of container is vizcontainer
# the container is created depends upon resourcegroupname and storageaccountname.
resource "azurerm_storage_account" "stgact" {
 name                     = "stgactname"
 resource_group_name      = azurerm_resource_group.newrg.name
 location                 = azurerm_resource_group.newrg.location
 account_tier             = "Standard"
 account_replication_type = "GRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "vizcontainer"
  storage_account_name  = azurerm_storage_account.stgact.name
  container_access_type = "private"
}

# virtual network can be  used to connect the virtual machine.a private IP address from the address space that i given.
# create vnet with CIDR 10.0.0.0/16 with 1 subnet with CIDR 10.0.2.0/24. Our virtual machine will be in this subnet. 
resource "azurerm_virtual_network" "vnetwork" {
  name                = "vnetwork"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.newrg.location
  resource_group_name = azurerm_resource_group.newrg.name
}

resource "azurerm_subnet" "newsub" {
  name                 = "newsub"
  resource_group_name  = azurerm_resource_group.newrg.name
  virtual_network_name = azurerm_virtual_network.vnetwork.name
  address_prefixes     = ["10.0.2.0/24"]
}

# To access our virtual machine, we need public IP. so i have used the allocation method is dynamic.it is only available once the resource 
# uses it available.
resource "azurerm_public_ip" "vm_public_ip" {
  name                = "vm_public_ip"
  resource_group_name = azurerm_resource_group.newrg.name
  location            = azurerm_resource_group.newrg.location
  allocation_method   = "Dynamic"
}

# network interface is connection between vm and underlying software.network interface have astatic and dynamic
# here i can attaching the  dyanamic ip address.
resource "azurerm_network_interface" "netinter" {
  name                = "netinter"
  location            = azurerm_resource_group.newrg.location
  resource_group_name = azurerm_resource_group.newrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.newsub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

# here im using the ssh connection so i allowed the ssh port number 
resource "azurerm_network_security_group" "nsg" {
  name                = "ssh_nsg"
  location            = azurerm_resource_group.newrg.location
  resource_group_name = azurerm_resource_group.newrg.name

  security_rule {
    name                       = "allow_ssh_sg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# the network interface is allowing access to the virtual machine.associate the network security group with network interface.
resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.netinter.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# here,creating the virtual machine and the size is standard_B2s.and attaching the network interface with virtual machine.and also created the# ssh to access the virtual machine.and using the image is ubuntu server 16.04.
resource "azurerm_linux_virtual_machine" "vmach" {
  name                  = "vmach"
  resource_group_name   = azurerm_resource_group.newrg.name
  location              = azurerm_resource_group.newrg.location
  size                  = "Standard_B2s"
  admin_username        = "vizualplatform"
  network_interface_ids = [	
    azurerm_network_interface.netinter.id,
  ]

  admin_ssh_key {
    username   = "vizualplatform"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

# output public IP so that we can connect to the machine using SSH.
output "public_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}
