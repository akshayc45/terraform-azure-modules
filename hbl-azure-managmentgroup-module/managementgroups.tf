#Author : Deval Sutaria
# This module will create management groups for HBL landing zone architecture
# NO CHANGES TO BE DONE IN ANY OF THE MODULE FILES

resource "azurerm_management_group" "hbl-mgroup" {
  for_each                   = var.managementgroups
  display_name               = each.value.display_name
  name                       = each.value.name
  subscription_ids           = try(each.value.subscriptionids, null)
  parent_management_group_id = try(each.value.parent_management_group_id, null)

}

##########################################################################
