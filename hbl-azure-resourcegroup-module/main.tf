locals {

  resource_creation = zipmap(var.rg_name, var.rg_location)
}
resource "azurerm_resource_group" "hbl_rg" {
  for_each = local.resource_creation
  name     = each.key
  location = each.value
  tags = merge({ "ResourceName" = "${each.key}" },
    var.rg_tags
  )
}