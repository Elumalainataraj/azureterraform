# the output will disply the storage account name and the resource group name
output "stgactname" {
  value = module.storageaccount.stg_act_name_out
}

output "nameresource" {
  value = module.resource_group.rg_name_out
}