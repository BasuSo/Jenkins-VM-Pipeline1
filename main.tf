variable "prefix" {
  default = "tfvmex"
}
##Resouce Group
resource "azurerm_resource_group" "VM" {
  name     = "Jenkins-RG"
  location = "Central India"
}
##virtual_network
resource "azurerm_virtual_network" "main" {
  name                = "Jenkins-VNET"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.VM.location
  resource_group_name = azurerm_resource_group.VM.name
}
##Subnet
resource "azurerm_subnet" "internal" {
  name                 = "MyfirstJenkinsVM_subnet1"
  resource_group_name  = azurerm_resource_group.VM.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}
##Public IP
resource "azurerm_public_ip" "PIP" {
  name                = "Jenkins-PIP1"
  resource_group_name = azurerm_resource_group.VM.name
  location            = azurerm_resource_group.VM.location
  allocation_method   = "Static"

  tags = {
    Environment = "Test"
    Owner = "Soumya"
    Project = "Jenkins-PoC"
  }
}
##Network Interface
resource "azurerm_network_interface" "main" {
  name                = "Jenkins-nic"
  location            = azurerm_resource_group.VM.location
  resource_group_name = azurerm_resource_group.VM.name
  #network_security_group_id = azurerm_network_security_group.NSG.id

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.PIP.id
  }
}
##NSG NIC Association
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.NSG.id
}
##Virtual Machine
resource "azurerm_linux_virtual_machine" "MyfirstJenkinsVM" {
  name                = "Jenkins-VM1"
  resource_group_name = azurerm_resource_group.VM.name
  location            = azurerm_resource_group.VM.location
  size                = "Standard_B2as_V2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("${path.module}/ssh/id_rsa.pub")
  }
  
  tags = {
    Owner       = "BasuSo"
    Project     = "Jenkins-VM-Pipeline1_Test"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  custom_data = base64encode(
    templatefile("${path.module}/Bootstrap.tftpl",{})
  )
}
##Netwrok Security Group
resource "azurerm_network_security_group" "NSG" {
  name                = "Jenkins-SG1"
  location            = azurerm_resource_group.VM.location
  resource_group_name = azurerm_resource_group.VM.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Jenkins"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    Environment = "Test"
    Owner = "Soumya"
    Project = "Jenkins-PoC"
  }
}