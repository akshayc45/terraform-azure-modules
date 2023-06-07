Route table terraform Module
----------------------------------------------
Terraform modules for multiple route table with route rules


Resources
-------------------------
Route table


Module Usages
-------------------------------
<!-- module "route_table" {
  source = "../../terraform-azure-lz/hbl-azure-route_tables-module"
  route_table = {
    "Route_table_1" = {
      location  = "centralindia"
      resource_group_name = "az-lz-test"
      route = [
        {
          routename = "rule1"
          address_prefix =  "0.0.0.0/0"
          next_hop_type = "Internet"
        }
        ]
    }
        "Route_table_2" = {
      location  = "centralindia"
      resource_group_name = "az-lz-test"
      route = [
        {
          routename = "rule1"
          address_prefix =  "0.0.0.0/0"
          next_hop_type = "Internet"
        }
        ]
    }
   }
} -->

output usages
----------------------------
module.route_table.route_table_output["Route_table_1"].id