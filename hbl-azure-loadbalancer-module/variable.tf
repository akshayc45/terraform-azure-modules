#-----------------------#
#----subnet variables---#
#-----------------------#
variable "lb_subnet_name" {
  type        = string
  default     = null
  description = "Name of subnet loadbalncer tobe deploy"
}
variable "lb_vnet_name" {
  type        = string
  default     = "test"
  description = "Name of vnet"
}
variable "lb_snet_resource_group" {
  type        = string
  default     = "centralindia"
  description = "location of subnet"
}

#-----------------------#
#----LB variables---#
#-----------------------#
variable "resource_group_name" {
  type        = string
  default     = "test-rg"
  description = "Resource Group Name for Load Balancer"
}
variable "location" {
  type        = string
  default     = "centralindia"
  description = "location Name for Load Balancer"
}
variable "pip_name" {
  type        = string
  default     = null
  description = "name of public ip"
}
variable "prefix" {
  type    = string
  default = "pip"
}
variable "allocation_method" {
  type        = string
  default     = "Dynamic"
  description = "(Required) Defines the allocation method for this IP address. Possible values are Static or Dynamic."
}
variable "pip_sku" {
  type        = string
  default     = null
  description = "The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic. Changing this forces a new resource to be created."
}
variable "ddos_protection_mode" {
  type        = string
  default     = "VirtualNetworkInherited"
  description = "The DDoS protection mode of the public IP. Possible values are Disabled, Enabled, and VirtualNetworkInherited. Defaults to VirtualNetworkInherited."
}
variable "ddos_protection_plan_id" {
  type        = string
  default     = null
  description = "The ID of DDoS protection plan associated with the public IP."
}
variable "tags_pip" {
  type        = any
  default     = {}
  description = "Tags for public Ip"
}
variable "loadbalancer_name" {
  type        = string
  default     = null
  description = "Name of loadbalancers"
}
variable "lb_sku" {
  type        = string
  default     = "Basic"
  description = "The SKU of the Azure Load Balancer. Accepted values are Basic, Standard and Gateway. Defaults to Basic. Changing this forces a new resource to be created."
}
variable "tags" {
  type        = any
  default     = {}
  description = "Load balancer tags"
}
variable "edge_zone" {
  type        = string
  default     = null
  description = "Specifies the Edge Zone within the Azure Region where this Load Balancer should exist. Changing this forces a new Load Balancer to be created."
}
variable "sku_tier" {
  type        = string
  default     = "Regional"
  description = "The SKU tier of this Load Balancer. Possible values are Global and Regional. Defaults to Regional. Changing this forces a new resource to be created."
}
variable "feip_configuration" {
  type        = any
  default     = []
  description = "frontend ip configuration block"
}
variable "type" {
  type        = string
  default     = null
  description = "type of loadbalncer set to public is public"
}
variable "virtual_network_id" {
  type        = string
  default     = null
  description = "The ID of the Virtual Network within which the Backend Address Pool should exist."
}
variable "tunnel_interface" {
  type        = any
  default     = []
  description = "Tunnel configuration"
  /*
    tunnel_interface = {
        [
            identifier = he unique identifier of this Gateway Lodbalancer Tunnel Interface.
            type  = The traffic type of this Gateway Lodbalancer Tunnel Interface. Possible values are None, Internal and External.
            protocol = The protocol used for this Gateway Lodbalancer Tunnel Interface. Possible values are None, Native and VXLAN.
            port =  The port number that this Gateway Lodbalancer Tunnel Interface listens to.
        ]
    }
    */

}
variable "nat_rule" {
  type        = any
  default     = {}
  description = "LoadBalancer NAT Rules. This resource is use for virtual machines"
  /*
    nat_rule = {
        [
            name                           = "RDPAccess"
            protocol                       = "Tcp"
            frontend_port                  = 3389
            backend_port                   = 3389
        ]
    }
    name - (Required) Specifies the name of the NAT Rule. Changing this forces a new resource to be created.
resource_group_name - (Required) The name of the resource group in which to create the resource. Changing this forces a new resource to be created.
loadbalancer_id - (Required) The ID of the Load Balancer in which to create the NAT Rule. Changing this forces a new resource to be created.
frontend_ip_configuration_name - (Required) The name of the frontend IP configuration exposing this rule.
protocol - (Required) The transport protocol for the external endpoint. Possible values are Udp, Tcp or All.
frontend_port - (Optional) The port for the external endpoint. Port numbers for each Rule must be unique within the Load Balancer. Possible values range between 1 and 65534, inclusive.
backend_port - (Required) The port used for internal connections on the endpoint. Possible values range between 1 and 65535, inclusive.
frontend_port_start - (Optional) The port range start for the external endpoint. This property is used together with BackendAddressPool and FrontendPortRangeEnd. Individual inbound NAT rule port mappings will be created for each backend address from BackendAddressPool. Acceptable values range from 1 to 65534, inclusive.
frontend_port_end - (Optional) The port range end for the external endpoint. This property is used together with BackendAddressPool and FrontendPortRangeStart. Individual inbound NAT rule port mappings will be created for each backend address from BackendAddressPool. Acceptable values range from 1 to 65534, inclusive.
backend_address_pool_id - (Optional) Specifies a reference to backendAddressPool resource.
idle_timeout_in_minutes - (Optional) Specifies the idle timeout in minutes for TCP connections. Valid values are between 4 and 30 minutes. Defaults to 4 minutes.
enable_floating_ip - (Optional) Are the Floating IPs enabled for this Load Balancer Rule? A "floating” IP is reassigned to a secondary server in case the primary server fails. Required to configure a SQL AlwaysOn Availability Group. Defaults to false.
enable_tcp_reset - (Optional) Is TCP Reset enabled for this Load Balancer Rule?
    */
}
# variable "lb_probe"{
#     type = any
#     default = {}
#     description = "LB Probes"
#     /*
#     lb_probe = {
#         [
#             name            = "ssh-running-probe"
#             port            = 22
#         ]
#     }
#     */
# }
variable "azlb_rule" {
  type        = any
  default     = {}
  description = ""
  /*
    azlb_rule = {
        [
    name - (Required) Specifies the name of the LB Rule. Changing this forces a new resource to be created.
loadbalancer_id - (Required) The ID of the Load Balancer in which to create the Rule. Changing this forces a new resource to be created.
frontend_ip_configuration_name - (Required) The name of the frontend IP configuration to which the rule is associated.
protocol - (Required) The transport protocol for the external endpoint. Possible values are Tcp, Udp or All
frontend_port - (Required) The port for the external endpoint. Port numbers for each Rule must be unique within the Load Balancer. Possible values range between 0 and 65534, inclusive.
backend_port - (Required) The port used for internal connections on the endpoint. Possible values range between 0 and 65535, inclusive.
backend_address_pool_ids - (Optional) A list of reference to a Backend Address Pool over which this Load Balancing Rule operates.
probe_id - (Optional) A reference to a Probe used by this Load Balancing Rule.
enable_floating_ip - (Optional) Are the Floating IPs enabled for this Load Balncer Rule? A floating IP is reassigned to a secondary server in case the primary server fails. Required to configure a SQL AlwaysOn Availability Group. Defaults to false.
idle_timeout_in_minutes - (Optional) Specifies the idle timeout in minutes for TCP connections. Valid values are between 4 and 30 minutes. Defaults to 4 minutes.
load_distribution - (Optional) Specifies the load balancing distribution type to be used by the Load Balancer. Possible values are: Default  The load balancer is configured to use a 5 tuple hash to map traffic to available servers. SourceIP  The load balancer is configured to use a 2 tuple hash to map traffic to available servers. SourceIPProtocol  The load balancer is configured to use a 3 tuple hash to map traffic to available servers. Also known as Session Persistence, where the options are called None, Client IP and Client IP and Protocol respectively.
disable_outbound_snat - (Optional) Is snat enabled for this Load Balancer Rule? Default false.
enable_tcp_reset - (Optional) Is TCP Reset enabled for this Load Balancer Rule?
],
[]
}
    */
}
variable "lb_nat_pool" {
  type        = any
  default     = {}
  description = "this resources use for vmss"
  /*
lb_nat_pool = {
    [
    name - (Required) Specifies the name of the NAT pool. Changing this forces a new resource to be created.
resource_group_name - (Required) The name of the resource group in which to create the resource. Changing this forces a new resource to be created.
loadbalancer_id - (Required) The ID of the Load Balancer in which to create the NAT pool. Changing this forces a new resource to be created.
frontend_ip_configuration_name - (Required) The name of the frontend IP configuration exposing this rule.
protocol - (Required) The transport protocol for the external endpoint. Possible values are All, Tcp and Udp.
frontend_port_start - (Required) The first port number in the range of external ports that will be used to provide Inbound NAT to NICs associated with this Load Balancer. Possible values range between 1 and 65534, inclusive.
frontend_port_end - (Required) The last port number in the range of external ports that will be used to provide Inbound NAT to NICs associated with this Load Balancer. Possible values range between 1 and 65534, inclusive.
backend_port - (Required) The port used for the internal endpoint. Possible values range between 1 and 65535, inclusive.
idle_timeout_in_minutes - (Optional) Specifies the idle timeout in minutes for TCP connections. Valid values are between 4 and 30. Defaults to 4.
floating_ip_enabled - (Optional) Are the floating IPs enabled for this Load Balancer Rule? A floating IP is reassigned to a secondary server in case the primary server fails. Required to configure a SQL AlwaysOn Availability Group.
tcp_reset_enabled - (Optional) Is TCP Reset enabled for this Load Balancer Rule?
]
}
*/

}


variable "number_address_pool" {
  type        = number
  default     = 1
  description = "nubmer of address pool tobe create"
}

variable "backend_pool_association" {
  type        = any
  default     = {}
  description = "The Name of the IP Configuration within the Network Interface which should be connected to the Backend Address Pool. Changing this forces a new resource to be created."
}