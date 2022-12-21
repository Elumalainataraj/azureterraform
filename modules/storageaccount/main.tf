#using the random provider for storage account
terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

#creating the random string here im not applying the special characters and upper case.
#this type is create a random string followed by storage account name
#resource "random_string" "random" {
#   length = 6
#   special = false
#   upper = false
#}

# create the storage account for resource group and adding the random 
#adding the lower for rgname.and the name is match to the resource group name
resource "azurerm_storage_account" "example" {
  name                     = "${lower(var.rgname)}${random_string.random.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}