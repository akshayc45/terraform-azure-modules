locals {
  subscription_id_1 = var.subscription_id_1
  #subscription_id_2 = var.subscription_ids[1]
}

provider "azurerm" {
  features {
    
  }
  alias           = "sub1"
  subscription_id = "${local.subscription_id_1}"
}

data "azurerm_resource_group" "rg1" {
  provider = azurerm.sub1
  name     = "${var.resource_group_names[0]}"
}


data "azurerm_virtual_network" "vnet1" {
  provider            = azurerm.sub1
  name                = "${var.vnet_names[0]}"
  resource_group_name = "${data.azurerm_resource_group.rg1.name}"
}


resource "azurerm_virtual_network_peering" "vnet_peer_1" {
  provider            = azurerm.sub1
  name                         = "${var.vnet_peering_names[0]}"
  resource_group_name          = "${data.azurerm_resource_group.rg1.name}"
  virtual_network_name         = "${data.azurerm_virtual_network.vnet1.name}"
  remote_virtual_network_id    = var.vnet2_id
  allow_virtual_network_access = "${var.allow_virtual_network_access}"
  allow_forwarded_traffic      = "${var.allow_forwarded_traffic}"
  use_remote_gateways          = "${var.use_remote_gateways1}"
  allow_gateway_transit        = "${var.allow_gateway_transit}"
}

resource "azurerm_virtual_network_peering" "vnet_peer_2" {
  #provider            = azurerm.sub2
  name                         = "${var.vnet_peering_names[1]}"
  resource_group_name          = "${var.resource_group_names[1]}"
  virtual_network_name         = "${var.vnet_names[1]}"
  remote_virtual_network_id    = var.vnet1_id
  allow_virtual_network_access = "${var.allow_virtual_network_access}"
  allow_forwarded_traffic      = "${var.allow_forwarded_traffic}"
  use_remote_gateways          = "${var.use_remote_gateways2}"
}