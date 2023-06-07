# This module will create subscriptions for HBL landing zone architecture
# NO CHANGES TO BE DONE IN ANY OF THE MODULE FILES
data "azurerm_billing_enrollment_account_scope" "hbl-acc-scope" {
  billing_account_name    = ""
  enrollment_account_name = ""
}

locals {
  finalsublist = merge(var.defaultsubmap, var.customsubmap)
}

resource "azurerm_subscription" "hbl-subscriptions" {
  for_each          = local.finalsublist
  subscription_name = each.value
  alias             = each.key
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.hbl-acc-scope.id
  tags              = merge({ "ResourceName" = each.value }, var.tags)
}
#######################################################################################
