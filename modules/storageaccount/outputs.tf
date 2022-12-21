#this output file is display the random string followed by the storage account name
output "stg_act_name_out" {
  value = resource.azurerm_storage_account.example.name
}