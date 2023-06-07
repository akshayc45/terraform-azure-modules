resource "azurerm_route_table" "hbl-routeTable"{
   for_each = var.route_table
   name =  each.key
   location  =  each.value["location"]
   resource_group_name = each.value["resource_group_name"]
   disable_bgp_route_propagation = try(each.value["disable_bgp_route_propagation"], false)
   tags = merge({"ResourceName" = each.key}, try(each.value.tags, null))


    dynamic "route" {
    for_each = lookup(each.value, "route", [])
    content {
    name           = route.value["routename"]
    address_prefix = route.value["address_prefix"]
    next_hop_type  = route.value["next_hop_type"]
    next_hop_in_ip_address = route.value["next_hop_type"] != "VirtualAppliance" ?  null : route.value["next_hop_in_ip_address"]
  }
    }
  }

