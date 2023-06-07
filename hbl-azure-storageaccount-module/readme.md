storagge account terraform Module
----------------------------------------------
Storage Account with all options.



Resources
-------------------------
azure storage account


Module Usages
------------------------------

module "storage_account" {
  source = ""
  storage_account = {
    "strorageaccount1" = {
  location = "centralindia"
  resource_group_name = "az-lz-test"
  custom_domain = [
    {
        
    }
  ]
    }
}
}