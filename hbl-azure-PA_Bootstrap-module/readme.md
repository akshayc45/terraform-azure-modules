Palo alto bootstrap 
----------------------------------------------
Terraform Module for palo alto firewall bootstrap. This module will create storage account for FW and directory struccture as require also upload bootstrap file in share directory.



Resources
-------------------------
azure storage account
azure file share
azure share folder


Module Usages
------------------------------
module "bootstrap" {
  source = "../terraform-azure-lz/hbl-zure-PA_Bootstrap-module"
  file_share_name = "bootstrapfiles"
share_directories = ["config","content","license","nonconfig","plugins","software","vmseries"]
source_file = ["./bootstrapfiles/config/init-cfg.txt"]
path_file = ["config"]
destination_file = ["init-cfg.txt"]
storage_account_name = "teststrg123097"
account_tier = "Standard"
account_replication_type = "LRS"
location =  "centralindia"
resource_group_name_for_internetinbound = "az-lz-test"
enable_https_traffic_only = true
} 
  