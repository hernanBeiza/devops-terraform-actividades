#Clúster productivo

#Crear un recurso
resource "azurerm_resource_group" "rg" {
  name      = var.name #"hbeiza"
  location  = var.location #"eastus2"
  tags    = {
    rg = "hbeiza"
  }
}

#Crear virtual network
resource "azurerm_virtual_network" "virtualnetwork" {
  name                  = "virtualnetworkhbeiza"
  address_space         = ["40.0.0.0/16"]
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
}

#Crear subnet
resource "azurerm_subnet" "subnet" {
  name                  = "subnetinternahbeiza"
  virtual_network_name  = azurerm_virtual_network.virtualnetwork.name
  address_prefixes      = ["40.0.4.0/24"]
  resource_group_name   = azurerm_resource_group.rg.name
}

#Container Registry
resource "azurerm_container_registry" "acrhbeiza" {
  name                  = "acrhbeiza"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  sku                   = "basic"
  admin_enabled         = true
}

#Cluster Kubernetes
resource "azurerm_kubernetes_cluster" "clusterakshbeiza" {
  name                = "aks1-hbeiza"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks1hbeiza"
  kubernetes_version  = "1.19.6"

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_D2_v2"
    # Usar una subnet antes declarada
    vnet_subnet_id      = azurerm_subnet.subnet.id
    #Subir o bajar los nodos automáticamente
    enable_auto_scaling = true
    max_count           = 2
    min_count           = 1
  }

  network_profile {
    network_plugin  = "azure"
    network_policy  = "azure"
  }

  tags = {
    Environment = "Production"
  }

  service_principal {
    client_id     = var.clientID
    client_secret = var.secret
  }

  role_based_access_control {
    enabled = true
    # Completar esta configuración
    /*
    azure_active_directory {
      client_app_id       = ""
      server_app_id       = ""
      server_app_secret   = ""
    }
    */
  }

}