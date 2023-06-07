locals {
  location      = var.location
  nw_watch_name = var.nw_watch_name
}

data "azurerm_storage_account" "ext_storag_account" {
  count               = var.storage_account_name != null ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = var.storage_account_resource_group_name
}

#-----------------------------
#----nsg_flowlogs_nw----------
#-----------------------------

resource "azurerm_network_watcher" "hbl-nw_watcher" {
  name                = local.nw_watch_name
  location            = local.location
  resource_group_name = var.nw_rg
  tags                = var.nw_tags
  depends_on          = [azurerm_network_security_group.hbl-nsg]
}
resource "azurerm_network_security_group" "hbl-nsg" {
  for_each            = var.nsgrule
  name                = each.key
  location            = each.value["location"]
  resource_group_name = each.value["resource_group_name"]
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


resource "azurerm_network_watcher_flow_log" "hbl-flow_logs" {
  for_each                  = var.nsgrule
  network_watcher_name      = local.nw_watch_name
  resource_group_name       = var.flowlogs_resource_group_name
  name                      = "${local.nw_watch_name}-flowlogs"
  network_security_group_id = azurerm_network_security_group.hbl-nsg[each.key].id
  storage_account_id        = var.storage_id != null ? var.storage_id : data.azurerm_storage_account.ext_storag_account[0].id
  #  storage_account_id        = data.azurerm_storage_account.ext_storag_account.id
  enabled  = var.enable_network_watcher_flow_log
  location = local.location

  dynamic "retention_policy" {
    for_each = var.retention_policy
    content {
      enabled = retention_policy.value["enabled"]
      days    = retention_policy.value["days"]
    }
  }

  dynamic "traffic_analytics" {
    for_each = var.traffic_analytics
    content {
      enabled               = traffic_analytics.value["enabled"]
      workspace_id          = traffic_analytics.value.workspace_id
      workspace_region      = traffic_analytics.value["workspace_region"]
      workspace_resource_id = traffic_analytics.value.log_analytics_workspace_resource_id
      interval_in_minutes   = traffic_analytics.value["interval_in_minutes"]
    }
  }
  depends_on = [azurerm_network_watcher.hbl-nw_watcher, azurerm_network_security_group.hbl-nsg]
  tags       = merge({ "ResourceName" = "${local.nw_watch_name}-flowlogs" }, var.flow_logs_tags)
}
