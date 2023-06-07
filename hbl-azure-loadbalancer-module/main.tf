locals {
  pip_name = var.pip_name != "" ? var.pip_name : format("%s-publicIP", var.prefix)
  lb_backend_address_pool_name_lb   = "${var.loadbalancer_name}-badpool${lower(random_id.sa_name_random.hex)}"
  frontend_ip_configuration_name_lb = "${var.loadbalancer_name}-feip"
  resource_group_name               = var.resource_group_name
  location                          = var.location
}

resource "random_id" "sa_name_random" {
  byte_length = 4
}

data "azurerm_subnet" "snet" {
  count                = var.lb_subnet_name != null ? 1 : 0
  name                 = var.lb_subnet_name
  virtual_network_name = var.lb_vnet_name
  resource_group_name  = var.lb_snet_resource_group
}

resource "azurerm_public_ip" "azlb_public_ip" {
  count = var.type == "public" ? 1 : 0
  name                 = local.pip_name
  resource_group_name  = local.resource_group_name
  location             = local.location
  allocation_method    = var.allocation_method
  sku                  = var.pip_sku
  ddos_protection_mode = var.ddos_protection_mode
  tags                 = var.tags_pip
}

resource "azurerm_lb" "azlb" {
  name                = var.loadbalancer_name
  resource_group_name = local.resource_group_name
  location            = local.location
  sku                 = var.lb_sku
  tags                = var.tags
  edge_zone           = var.edge_zone
  sku_tier            = var.sku_tier

  dynamic "frontend_ip_configuration" {
    for_each = var.feip_configuration
    content {
      name                                               = frontend_ip_configuration.value.name
      public_ip_address_id                               = var.type == "public" ? join("", azurerm_public_ip.azlb_public_ip.*.id) : null
      subnet_id                                          = try(frontend_ip_configuration.value.subnet_id, data.azurerm_subnet.snet[0].id)
      private_ip_address                                 = lookup(frontend_ip_configuration.value, "private_ip_address", null)
      private_ip_address_allocation                      = lookup(frontend_ip_configuration.value, "private_ip_address_allocation", "Dynamic")
      gateway_load_balancer_frontend_ip_configuration_id = lookup(frontend_ip_configuration.value, "gateway_load_balancer_frontend_ip_configuration_id", null)
      zones                                              = lookup(frontend_ip_configuration.value, "zones", null)
      private_ip_address_version                         = lookup(frontend_ip_configuration.value, "private_ip_address_version", null)
      public_ip_prefix_id                                = lookup(frontend_ip_configuration.value, "public_ip_prefix_id", null)
    }
  }

}

resource "azurerm_lb_backend_address_pool" "azlb_backend_pool" {
  count              = var.number_address_pool
  name               = local.lb_backend_address_pool_name_lb
  loadbalancer_id    = azurerm_lb.azlb.id
  virtual_network_id = try(var.virtual_network_id, null)
  dynamic "tunnel_interface" {
    for_each = var.tunnel_interface
    content {
      identifier = tunnel_interface.value.identifier
      type       = tunnel_interface.value.type
      protocol   = tunnel_interface.value.protocol
      port       = tunnel_interface.value.port
    }
  }
}

resource "azurerm_lb_nat_rule" "azlb_nat_ule" {
  #count                          = length(var.remote_port)
  for_each            = var.nat_rule
  name                = each.key
  resource_group_name = local.resource_group_name
  loadbalancer_id     = azurerm_lb.azlb.id
  protocol            = each.value.protocol
  frontend_port       = try(each.value.frontend_port, null)
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  frontend_port_start            = try(each.value.frontend_port_start, null)
  frontend_port_end              = try(each.value.frontend_port_end, null)
  backend_address_pool_id        = try(azurerm_lb_backend_address_pool.azlb_backend_pool[0].id, null)
  idle_timeout_in_minutes        = try(each.value.idle_timeout_in_minutes, null)
  enable_floating_ip             = try(each.value.enable_floating_ip, null)
  enable_tcp_reset               = try(each.value.enable_tcp_reset, null)
  depends_on = [
    azurerm_lb.azlb
  ]
}
#
resource "azurerm_lb_probe" "azlb_probe" {
  for_each            = var.azlb_rule
  name                = "${each.key}-probe"
  port                = each.value.backend_port
  loadbalancer_id     = azurerm_lb.azlb.id
  protocol            = try(each.value.protocol, null)
  interval_in_seconds = try(each.value.interval_in_seconds, null)
  number_of_probes    = try(each.value.number_of_probes, null)
  request_path        = try(each.value.request_path, null)
  probe_threshold     = try(each.value.probe_threshold, null)
  depends_on          = [azurerm_lb.azlb]
}
#
resource "azurerm_lb_rule" "azlb_rule" {
  for_each = var.azlb_rule
  name     = each.key
  loadbalancer_id                = azurerm_lb.azlb.id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  enable_floating_ip             = try(each.value.enable_floating_ip_lb_rule, null)
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.azlb_backend_pool[0].id]
  idle_timeout_in_minutes        = try(each.value.idle_timeout_in_minutes, null)
  probe_id                       = azurerm_lb_probe.azlb_probe[each.key].id
  load_distribution              = try(each.value.load_distribution, null)
  disable_outbound_snat          = try(each.value.disable_outbound_snat, null)
  enable_tcp_reset               = try(each.value.enable_tcp_reset, null)
  depends_on = [
    azurerm_lb.azlb
  ]
}


resource "azurerm_lb_nat_pool" "example" {
  for_each                       = var.lb_nat_pool
  resource_group_name            = local.resource_group_name
  loadbalancer_id                = azurerm_lb.azlb.id
  name                           = each.value.name
  protocol                       = each.value.protocol
  frontend_port_start            = each.value.port_start
  frontend_port_end              = each.value.port_end
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  floating_ip_enabled            = each.value.floating_ip_enabled
  tcp_reset_enabled              = each.value.tcp_reset_enabled
}

resource "azurerm_network_interface_backend_address_pool_association" "pool_association" {
  for_each                = var.backend_pool_association
  network_interface_id    = each.value.network_interface_id
  ip_configuration_name   = each.value.ip_configuration_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.azlb_backend_pool[0].id
  depends_on              = [azurerm_lb_backend_address_pool.azlb_backend_pool]
}
