#Clúster Simple

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
  address_space         = ["10.0.0.0/16"]
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
}

#Crear subnet
resource "azurerm_subnet" "subnet" {
  name                  = "subnetinterna"
  virtual_network_name  = azurerm_virtual_network.virtualnetwork.name
  address_prefixes      = ["10.0.4.0/16"]
  resource_group_name   = azurerm_resource_group.rg.name
}

#Cluster Kubernetes
resource "azurerm_kubernetes_cluster" "clusterakshbeiza" {
  name                = "hbeiza-aks1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "hbeizaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  # La IP se la autoasignará de una subnet creada por si mismo

  # Eliminado porque se usa service_principal
  #identity {
  #  type = "SystemAssigned"
  #}

  tags = {
    Environment = "Production"
  }

  service_principal {
    client_id     = var.clientID
    client_secret = var.secret
  }

}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.clusterakshbeiza.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.clusterakshbeiza.kube_config_raw
}