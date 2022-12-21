# output will display the name of the resource group name
output "rg_name_out" {
   value = azurerm_resource_group.viz.name
}