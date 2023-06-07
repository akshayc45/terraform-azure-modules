variable "storage_account_name" {
  type        = string
  default     = null
  description = "storage account name"
}
variable "storage_account_resource_group_name" {
  type        = string
  default     = null
  description = "storage account resource group"
}

#-------------------
#nsg_nw_variables---
#-------------------

variable "location" {
  type        = string
  default     = "southindia"
  description = "location"
}
variable "nw_watch_name" {
  type        = string
  default     = "tf-nw"
  description = "network watcher name"
}
variable "nw_rg" {
  type        = string
  default     = "test-rg"
  description = "network watcher resource group"
}
variable "nw_tags" {
  type        = any
  default     = {}
  description = "network tags"
}
variable "nsgrule" {
  type        = any
  default     = {}
  description = "network security rules"
  /*
    nsgrule = {
    "nsg_name = {
    name - (Required) Specifies the name of the network security group. Changing this forces a new resource to be created.
resource_group_name - (Required) The name of the resource group in which to create the network security group. Changing this forces a new resource to be created.
location - (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created.
security_rule = {
    [
name - (Required) The name of the security rule.
description - (Optional) A description for this rule. Restricted to 140 characters.
protocol - (Required) Network protocol this rule applies to. Possible values include Tcp, Udp, Icmp, Esp, Ah or * (which matches all).
source_port_range - (Optional) Source Port or Range. Integer or range between 0 and 65535 or * to match any. This is required if source_port_ranges is not specified.
source_port_ranges - (Optional) List of source ports or port ranges. This is required if source_port_range is not specified.
destination_port_range - (Optional) Destination Port or Range. Integer or range between 0 and 65535 or * to match any. This is required if destination_port_ranges is not specified.
destination_port_ranges - (Optional) List of destination ports or port ranges. This is required if destination_port_range is not specified.
source_address_prefix - (Optional) CIDR or source IP range or * to match any IP. Tags such as VirtualNetwork, AzureLoadBalancer and Internet can also be used. This is required if source_address_prefixes is not specified.
source_address_prefixes - (Optional) List of source address prefixes. Tags may not be used. This is required if source_address_prefix is not specified.
destination_address_prefix - (Optional) CIDR or destination IP range or * to match any IP. Tags such as VirtualNetwork, AzureLoadBalancer and Internet can also be used. This is required if destination_address_prefixes is not specified.
destination_address_prefixes - (Optional) List of destination address prefixes. Tags may not be used. This is required if destination_address_prefix is not specified.
destination_application_security_group_ids - (Optional) A List of destination Application Security Group IDs
access - (Required) Specifies whether network traffic is allowed or denied. Possible values are Allow and Deny.
priority - (Required) Specifies the priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule.
direction - (Required) The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are Inbound and Outbound.
]
    }
    }
    }
    */
}
variable "flowlogs_resource_group_name" {
  type        = string
  default     = "test-rg"
  description = "flowlogs resource group"
}
variable "storage_id" {
  type        = string
  default     = "test"
  description = "The ID of the Storage Account where flow logs are stored."
}
variable "enable_network_watcher_flow_log" {
  type        = bool
  default     = true
  description = "Should Network Flow Logging be Enabled?"
}
variable "retention_policy" {
  type        = any
  default     = {}
  description = "The number of days to retain flow log records."
}
variable "traffic_analytics" {
  type        = any
  default     = {}
  description = "traffic analytiics block"
}

variable "flow_logs_tags" {
  type        = map(any)
  default     = {}
  description = "map value for flow logs tags"
}