variable "subscription_id_1" {
  type = string
  default = null
  description = "subscription id of vnet that need to peer with"
}

variable "vnet_peering_names" {
  type        = list
  description = "Name of the virtual network peerings to be created in both virtual networks provided in list format."
}

variable "vnet_names" {
  type        = list
  description = "Names of the both virtual networks peered provided in list format."
}

variable "virtual_network_id_2" {
  type = string
  default = "value"
  description = "virtual network id for peering"
}

variable "resource_group_names" {
  type        = list
  description = "Names of both Resources groups of the respective virtual networks provided in list format"
}


variable "subscription_ids" {
  type        = list
  description = "List of two subscription ID's provided in cause of allow_cross_subscription_peering set to true."
  default     = ["", ""]
}

variable "allow_virtual_network_access" {
  description = "Controls if the VMs in the remote virtual network can access VMs in the local virtual network. Defaults to false."
  default     = true
}

variable "allow_forwarded_traffic" {
  description = "Controls if forwarded traffic from VMs in the remote virtual network is allowed. Defaults to false."
  default     = true
}

variable "allow_gateway_transit" {
  description = "Controls gatewayLinks can be used in the remote virtual network’s link to the local virtual network. Must be set to false for Global VNET peering."
  default     = true
}

variable "use_remote_gateways1" {
  description = "(Optional) Controls if remote gateways can be used on the local virtual network. If the flag is set to true, and allow_gateway_transit on the remote peering is also true, virtual network will use gateways of remote virtual network for transit. Defaults to false."
  default     = false
}
variable "use_remote_gateways2" {
  description = "(Optional) Controls if remote gateways can be used on the local virtual network. If the flag is set to true, and allow_gateway_transit on the remote peering is also true, virtual network will use gateways of remote virtual network for transit. Defaults to false."
  default     = false
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)
  default = {}
}

variable "vnet1_id" {
  type = string
  default = null
}
variable "vnet2_id" {
  type = string
  default = null
}


