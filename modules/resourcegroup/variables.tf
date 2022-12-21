#the name of the resource group name and storage account.location resourcegroup working location
variable "rgname" {
    type = string
    description = "the name for resource group and storage account"
}

variable "location" {
  type = string
  description = "the location for resource group and working in this location"
}