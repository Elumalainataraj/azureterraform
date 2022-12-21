# this use case is used to main.tf file.the variables mentioned in resourece group name and 
# storage account name.and location
variable "rgname" {
    type = string
    description = "the storage account name"
}

variable "resource_group_name" {
    type = string 
    description = "name of resource group"
}

variable "location" {
    type = string
    description = "location of storage account"
}