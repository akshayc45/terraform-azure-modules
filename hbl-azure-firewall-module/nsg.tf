

resource "azurerm_network_security_group" "nsg" {
  for_each            = var.nsgrule
  name                = each.key
  resource_group_name = local.resource_group_name
  location            = local.location
  tags                = merge({ "ResourceName" = each.key }, each.value["tags"])

  dynamic "security_rule" {
    for_each = lookup(each.value, "security_rule", [])
    content {
      name                         = lookup(security_rule.value, "name", null)
      priority                     = lookup(security_rule.value, "priority", null)
      direction                    = lookup(security_rule.value, "direction", null)
      access                       = lookup(security_rule.value, "access", null)
      protocol                     = lookup(security_rule.value, "protocol", null)
      source_port_range            = try(security_rule.value.source_port_range, null)
      source_port_ranges           = try(security_rule.value.source_port_ranges, null)
      destination_port_range       = try(security_rule.value.destination_port_range, null)
      destination_port_ranges      = try(security_rule.value.destination_port_ranges, null)
      source_address_prefix        = try(security_rule.value.source_address_prefix, null)
      source_address_prefixes      = try(security_rule.value.source_address_prefixes, null)
      destination_address_prefix   = try(security_rule.value.destination_address_prefix, null)
      destination_address_prefixes = try(security_rule.value.destination_address_prefixes, null)
      description                  = lookup(security_rule.value, "description", null)
    }
  }
}

