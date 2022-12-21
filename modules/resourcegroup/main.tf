#the name of the resource group and where this resource group deployed in this location
#the name of the resource groupo followed by the "RG"using the variable
resource "azurerm_resource_group" "viz" {
  name     = "${var.rgname}RG"
  location = var.location
}