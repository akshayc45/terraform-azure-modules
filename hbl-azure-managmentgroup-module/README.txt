#filename : managementgroups.tf
#variables file : variables.tf
#purpose : this code created management group hierarchy upto level 3
#Author : Deval Sutaria , CXIO
# Module files should not be changed in any case. These files are reusable and values must be passed from outside module.

Management Group terraform Module
----------------------------------------------
multiple level management Group creation and association with subscription.



Resources
-------------------------
management groups hierarchy
subscription association


Module Usages
------------------------------

module "mgm1" {
  source = "../../terraform-azure-lz/hbl-azure-managmentgroup-module"
  managementgroups = {
  "level-1" = {
  display_name = "test-mgm1"
  name = "testmg1"
  }
}
}


module "mgm2" {
  source = "../../terraform-azure-lz/hbl-azure-managmentgroup-module"
  managementgroups = {
  "level-2" = {
  display_name = "test-mgm2"
  name = "testmg2"
  parent_management_group_id = module.mgm1.managementgroups["level-1"].id
  #subscriptionids = []
  }
}
}