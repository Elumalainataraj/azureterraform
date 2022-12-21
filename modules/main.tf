# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }    
 backend "azurerm" {
 resource_group_name   = "vizualexample"      
 storage_account_name  = "vizualexample"     
 container_name        = "tstate"     
 key                   = "terraform.tfstate"   
 } 
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# here the resource group and storage account call from the modules directory
# the source is current dirctory so given the "./"
module "resource_group" {
  source   = "./resourcegroup"
  rgname   = "vizualexample"
  location = "centralindia"
}

module "storageaccount" {
  source              = "./storageaccount"
  rgname              = "vizualexample"
  resource_group_name = module.resource_group.rg_name_out
  location            = "centralindia"
}