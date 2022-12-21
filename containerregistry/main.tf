# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
 
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name                  = "example-resources"
  location              = "centralindia"
}

#resource "azurerm_container_registry" "acr" {
#  name                = "vizualcontainer"
#  resource_group_name = azurerm_resource_group.example.name
#  location            = azurerm_resource_group.example.location
#  sku                 = "Standard"
#  admin_enabled       = false
#}

#resource "azurerm_container_registry_webhook" "webhook" {
#  name                = "mywebhook"
#  resource_group_name = azurerm_resource_group.example.name
#  registry_name       = azurerm_container_registry.acr.name
#  location            = azurerm_resource_group.example.location

#  service_uri = "https://mywebhookreceiver.example/mytag"
#  status      = "enabled"
#  scope       = "mytag:*"
#  actions     = ["push"]
#  custom_headers = {
#    "Content-Type" = "application/json"
#  }
# }


# Azure Container Registry allows you to build store and manage container images and artifacts in a private registry for all types of container deployments. 
# Use Azure container registries with your existing container development and deployment pipelines.
# These images can then be pulled and run locally or used for container-based deployments to hosting platforms.
# The container registry name is vizcontainer.and the container is deployed in resource group location.
resource "azurerm_container_registry" "acr" {
  name                = "vizcontainer"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Premium"
}

#When deploying clusters with AKS, the service manages your Kubernetes masters while you manage your worker nodes.
#A node pool is a group of nodes within a cluster that all have the same configuration. Node pool use a NodeConfig specification
#A identity block should be configured on this Container Registry. 
resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
} 

# Assigns a given Principal (User or Group) to a given Role.
# create a role-assignment on the container registry for the built-in role of AcrPull.
resource "azurerm_role_assignment" "example" {
  principal_id                     = azurerm_kubernetes_cluster.example.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
