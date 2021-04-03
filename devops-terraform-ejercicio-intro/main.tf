provider "azurerm" {
  #Subscription ID
  subscription_id = "513140d0-b180-4730-9451-6bbbdecdbc57"
  #Application ID
  client_id = "13be9e94-96a2-4f0f-b076-58316448723d"
  #Secret
  client_secret = "7ibBX-5mu~Ez1DPN.4yqH1apZcEX.6Pofs"
  #Directory tenant
  tenant_id	= "b61edac7-725c-4319-8919-13d2d6bd013e"

  features {}
}

#Crear un recurso
resource "azurerm_resource_group" "rg" {
  name = var.name #"hbeiza"
  location  = var.location #"eastus2"
  tags    = {
    rg = "hbeiza"
  }
}

#Crear virtual network
resource "azurerm_virtual_network" "virtualnetwork" {
  name = "virtualnetworkhbeiza"
  address_space = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
}

#Crear subnet
resource "azurerm_subnet" "subnet" {
  name = "subnetinterna"
  virtual_network_name = azurerm_virtual_network.virtualnetwork.name
  address_prefixes = ["10.0.4.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
}

#Crear ip pública
resource "azurerm_public_ip" "publicip" {
  name = "publiciphbeiza"
  resource_group_name = azurerm_resource_group.rg.name
  location  = azurerm_resource_group.rg.location
  allocation_method = "Static"
}

#Crear interfaz de red
resource "azurerm_network_interface" "networkinterface" {
  name = "networkinterfacehbeiza"
  location  = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name = "interna"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Crear una máquina
resource "azurerm_linux_virtual_machine" "virtualmachine" {
  name = "virtualmachinehb"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size = "Standard_B1ls"
  network_interface_ids = [azurerm_network_interface.networkinterface.id]
  admin_username = "hb"
  admin_password = "hb"
  disable_password_authentication = false
  computer_name = "hostname"
  #no es storage, es source
  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04-LTS"
    version = "latest"
  }
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
}