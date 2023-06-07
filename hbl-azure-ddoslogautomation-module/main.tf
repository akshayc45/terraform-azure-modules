resource "azurerm_network_ddos_protection_plan" "hbl-ddos_prt" {
  for_each            = var.ddos_prt
  name                = each.value["name"]
  location            = each.value["location"]
  resource_group_name = each.value["rgname"]
  tags                = merge({ "ResourceName" = each.value["name"] }, each.value["tags"], )
}

