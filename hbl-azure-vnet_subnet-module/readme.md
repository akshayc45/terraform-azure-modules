Vnet Subnet terraform Module
----------------------------------------------
azure virtual network and subnet creation



Resources
-------------------------
azure virtual network
azure virtual network DDOS association
azure subnet
subnet association with NSG
subnet association with UDR
subnet delegation



Module Usages
------------------------------
<!-- module "hbl_DR_resourcegroup" {
    source = "../../terraform-azure-lz/hbl-azure-vnet_subnet-module"
  resource_group_name = "resource_group_name"
  vnet_location = "centralindia"
  vnet_name = "vnet_name"
  address_space = ["110.10.0.0/16"]
  subnet_prefixes = ["10.10.10.0/24"]
  subnet_names = ["subnet11"]
  ddos_protection_enable = true
  ddos_protection_id     = "DDOS_ID"
  subnet_names = ["subnet11"]
   route_tables_ids = {
      subnet11 = "route_table_id"
     }
  subnet_service_endpoints = {
  	subnet11t = [ "Microsoft.Storage" ]
}
} -->