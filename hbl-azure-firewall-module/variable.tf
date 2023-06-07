#---------------------------------------------------------#
#-------------------WAF POLICY-------------------#
#---------------------------------------------------------#
variable "waf_policy_tags" {
  type    = map(any)
  default = {}
}
variable "policy_settings" {
  type    = any
  default = {}
}
variable "managed_rules" {
  type    = any
  default = {}
}
variable "custom_policies" {
  type    = any
  default = []
}
variable "managed_policies_exclusions" {
  type    = any
  default = []
}
#---------------------------------------------------------#
#-------------------APPLICATION GATEWAY-------------------#
#---------------------------------------------------------#
variable "creat_apg" {
  description = "Whether to create application gateway"
  type        = bool
  default     = false
}

variable "lbresource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = ""
}

variable "lblocation" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = ""
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  default     = ""
}

variable "vnet_resource_group_name" {
  description = "The resource group name where the virtual network is created"
  default     = null
}

variable "subnet_name" {
  description = "The name of the subnet to use in VM scale set"
  default     = ""
}

variable "app_gateway_name" {
  description = "The name of the application gateway"
  default     = ""
}

variable "log_analytics_workspace_name" {
  description = "The name of log analytics workspace name"
  default     = null
}

variable "creatpip" {
  type    = bool
  default = false
}

variable "storage_account_name" {
  description = "The name of the hub storage account to store logs"
  default     = null
}

variable "domain_name_label" {
  description = "Label for the Domain Name. Will be used to make up the FQDN."
  default     = null
}

variable "enable_http2" {
  description = "Is HTTP2 enabled on the application gateway resource?"
  default     = false
}

variable "isfips_enabled" {
  type        = bool
  description = "(Optional) Is FIPS enabled on the Application Gateway?"
  default     = false
}

variable "zones" {
  description = "A collection of availability zones to spread the Application Gateway over."
  type        = list(string)
  default     = [] #["1", "2", "3"]
}

variable "firewall_policy_id" {
  description = "The ID of the Web Application Firewall Policy which can be associated with app gateway"
  default     = null
}

variable "sku" {
  description = "The sku pricing model of v1 and v2"
  type = object({
    name     = string
    tier     = string
    capacity = optional(number)
  })
}

variable "autoscale_configuration" {
  description = "Minimum or Maximum capacity for autoscaling. Accepted values are for Minimum in the range 0 to 100 and for Maximum in the range 2 to 125"
  type = object({
    min_capacity = number
    max_capacity = optional(number)
  })
  default = null
}

variable "frontend_port" {
  description = " (Required) One or more frontend_port blocks."
  type        = any
  default     = []
}

variable "global" {
  description = "global setting"
  type        = any
  default     = []
}

variable "private_link_configuration" {
  description = ""
  type        = any
  default     = {}
}
variable "gateway_ip_configuration" {
  description = "(Required) One or more gateway_ip_configuration blocks."
  type        = any
  default     = []
}

variable "private_ip_address" {
  description = "Private IP Address to assign to the Load Balancer."
  default     = null
}

variable "trusted_client_certificate" {
  type    = any
  default = []
}

variable "force_firewall_policy_association" {
  description = " (Optional) Is the Firewall Policy associated with the Application Gateway?"
  default     = false
  type        = bool
}

variable "backend_address_pools" {
  description = "List of backend address pools"
  type = list(object({
    name         = string
    fqdns        = optional(list(string))
    ip_addresses = optional(list(string))
  }))
}

variable "backend_http_settings" {
  description = "List of backend HTTP settings."
  # type = list(object({
  #   name                                = string
  #   cookie_based_affinity               = string
  #   affinity_cookie_name                = optional(string)
  #   path                                = optional(string)
  #   #enable_https                        = bool
  #   probe_name                          = optional(string)
  #   request_timeout                     = number
  #   host_name                           = optional(string)
  #   pick_host_name_from_backend_address = optional(bool)
  #   authentication_certificate = optional(object({
  #     name = string
  #   }))
  #   trusted_root_certificate_names = optional(list(string))
  #   connection_draining = optional(object({
  #     enable_connection_draining = bool
  #     drain_timeout_sec          = number
  #   }))
  # }))
  type    = any
  default = []
}

variable "frontend_ip_configuration" {
  type    = any
  default = []
}
variable "ssl_profile" {
  type    = any
  default = []
}


variable "http_listeners" {
  description = "List of HTTP/HTTPS listeners. SSL Certificate name is required"
  type = list(object({
    name                 = string
    host_name            = optional(string)
    host_names           = optional(list(string))
    require_sni          = optional(bool)
    ssl_certificate_name = optional(string)
    firewall_policy_id   = optional(string)
    ssl_profile_name     = optional(string)
    custom_error_configuration = optional(list(object({
      status_code           = string
      custom_error_page_url = string
    })))
  }))
  default = []
}

variable "request_routing_rules" {
  description = "List of Request routing rules to be used for listeners."
  # type = list(object({
  #   name                        = string
  #   rule_type                   = string
  #   http_listener_name          = string
  #   backend_address_pool_name   = optional(string)
  #   backend_http_settings_name  = optional(string)
  #   redirect_configuration_name = optional(string)
  #   rewrite_rule_set_name       = optional(string)
  #   url_path_map_name           = optional(string)
  # }))
  type    = any
  default = []
}

variable "identity_ids" {
  description = "Specifies a list with a single user managed identity id to be assigned to the Application Gateway"
  default     = null
}

variable "identity_type" {
  description = "Specifies a list with a single user managed identity id to be assigned to the Application Gateway"
  default     = null
}


variable "authentication_certificates" {
  description = "Authentication certificates to allow the backend with Azure Application Gateway"
  type = list(object({
    name = string
    data = string
  }))
  default = []
}

variable "trusted_root_certificates" {
  description = "Trusted root certificates to allow the backend with Azure Application Gateway"
  type = list(object({
    name = string
    data = string
  }))
  default = []
}

variable "ssl_policy" {
  description = "Application Gateway SSL configuration"
  type = object({
    disabled_protocols   = optional(list(string))
    policy_type          = optional(string)
    policy_name          = optional(string)
    cipher_suites        = optional(list(string))
    min_protocol_version = optional(string)
  })
  default = null
}

variable "ssl_certificates" {
  description = "List of SSL certificates data for Application gateway"
  type = list(object({
    name                = string
    data                = optional(string)
    password            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default = []
}

variable "health_probes" {
  description = "List of Health probes used to test backend pools health."
  # type = list(object({
  #   name                                      = string
  #   host                                      = string
  #   interval                                  = number
  #   path                                      = string
  #   timeout                                   = number
  #   unhealthy_threshold                       = number
  #   port                                      = optional(number)
  #   pick_host_name_from_backend_http_settings = optional(bool)
  #   minimum_servers                           = optional(number)
  #   match = optional(object({
  #     body        = optional(string)
  #     status_code = optional(list(string))
  #   }))
  # }))
  type    = any
  default = {}
}

variable "url_path_maps" {
  description = "List of URL path maps associated to path-based rules."
  type = list(object({
    name                                = string
    default_backend_http_settings_name  = optional(string)
    default_backend_address_pool_name   = optional(string)
    default_redirect_configuration_name = optional(string)
    default_rewrite_rule_set_name       = optional(string)
    path_rules = list(object({
      name                        = string
      backend_address_pool_name   = optional(string)
      backend_http_settings_name  = optional(string)
      paths                       = list(string)
      redirect_configuration_name = optional(string)
      rewrite_rule_set_name       = optional(string)
      firewall_policy_id          = optional(string)
    }))
  }))
  default = []
}

variable "redirect_configuration" {
  description = "list of maps for redirect configurations"
  type        = list(map(string))
  default     = []
}

variable "custom_error_configuration" {
  description = "Global level custom error configuration for application gateway"
  type        = list(map(string))
  default     = []
}

variable "rewrite_rule_set" {
  description = "List of rewrite rule set including rewrite rules"
  type        = any
  default     = []
}

variable "waf_configuration" {
  description = "Web Application Firewall support for your Azure Application Gateway"
  type = object({
    firewall_mode            = string
    rule_set_version         = string
    file_upload_limit_mb     = optional(number)
    request_body_check       = optional(bool)
    max_request_body_size_kb = optional(number)
    disabled_rule_group = optional(list(object({
      rule_group_name = string
      rules           = optional(list(string))
    })))
    exclusion = optional(list(object({
      match_variable          = string
      selector_match_operator = optional(string)
      selector                = optional(string)
    })))
  })
  default = null
}

variable "agw_diag_logs" {
  description = "Application Gateway Monitoring Category details for Azure Diagnostic setting"
  default     = ["ApplicationGatewayAccessLog", "ApplicationGatewayPerformanceLog", "ApplicationGatewayFirewallLog"]
}

variable "pip_diag_logs" {
  description = "Load balancer Public IP Monitoring Category details for Azure Diagnostic setting"
  default     = ["DDoSProtectionNotifications", "DDoSMitigationFlowLogs", "DDoSMitigationReports"]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

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
# variable "tags" {
#   type        = any
#   default     = {}
#   description = "Load balancer tags"
# }
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


#-----------------------
#---- NSG---------------
#-----------------------

variable "nsgrule" {
  type = any
  default = {}
  description = "Network security group"
}


#-----------------------
#---- vmss---------------
#-----------------------

variable "source_image_reference" {
  type        = any
  default     = {}
  description = "source image details"
}

variable "plan" {
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  default     = null
  description = <<-EOT
  object({
    name      = "(Required) Specifies the Name of the Marketplace Image this Virtual Machine should be created from. Changing this forces a new resource to be created."
    product   = "(Required) Specifies the Product of the Marketplace Image this Virtual Machine should be created from. Changing this forces a new resource to be created."
    publisher = "(Required) Specifies the Publisher of the Marketplace Image this Virtual Machine should be created from. Changing this forces a new resource to be created."
  })
  EOT
}

variable "os_disk" {
  type        = any
  default     = {}
  description = "os disk block"
}

variable "data_disk" {
  type    = any
  default = []
}

variable "extension" {
  type        = any
  default     = []
  description = <<-EOT
  name - (Required) The name for the Virtual Machine Scale Set Extension.
publisher - (Required) Specifies the Publisher of the Extension.
type - (Required) Specifies the Type of the Extension.
type_handler_version - (Required) Specifies the version of the extension to use, available versions can be found using the Azure CLI.
auto_upgrade_minor_version - (Optional) Should the latest version of the Extension be used at Deployment Time, if one is available? This won't auto-update the extension on existing installation. Defaults to true.
automatic_upgrade_enabled - (Optional) Should the Extension be automatically updated whenever the Publisher releases a new version of this VM Extension?
force_update_tag - (Optional) A value which, when different to the previous value can be used to force-run the Extension even if the Extension Configuration hasn't changed.
protected_settings - (Optional) A JSON String which specifies Sensitive Settings (such as Passwords) for the Extension.
EOT
}

variable "virtual_machine_scale_set" {
  type        = any
  default     = {}
  description = "virtual_machine_scale_set values"
}


variable "gallery_application" {
  type        = any
  default     = []
  description = <<-EOT
  version_id - (Required) Specifies the Gallery Application Version resource ID. Changing this forces a new resource to be created.
configuration_blob_uri - (Optional) Specifies the URI to an Azure Blob that will replace the default configuration for the package if provided. Changing this forces a new resource to be created.
order - (Optional) Specifies the order in which the packages have to be installed. Possible values are between 0 and 2,147,483,647. Changing this forces a new resource to be created.
tag - (Optional) Specifies a passthrough value for more generic context. This field can be any valid string value. Changing this forces a new resource to be created.
EOT
}


variable "network_interface" {
  type    = any
  default = {}
}

variable "identity" {
  type        = any
  default     = []
  description = <<-EOT
  object({
    type         = "(Required) Specifies the type of Managed Service Identity that should be configured on this Linux Virtual Machine. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both)."
    identity_ids = "(Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Linux Virtual Machine. This is required when `type` is set to `UserAssigned` or `SystemAssigned, UserAssigned`."
  })
  EOT
}

variable "secrets" {
  type        = any
  default     = []
  description = <<-EOT
   secrets = [
    {
    key_vault_id = "(Required) The ID of the Key Vault from which all Secrets should be sourced."
    certificate  = set(object({
      url   = "(Required) The Secret URL of a Key Vault Certificate. This can be sourced from the `secret_id` field within the `azurerm_key_vault_certificate` Resource."
      store = "(Optional) The certificate store on the Virtual Machine where the certificate should be added. Required when use with Windows Virtual Machine."
    }
    ]
  EOT
  #nullable    = false
}

variable "termination_notification" {
  type        = any
  default     = null
  description = "test"
}

variable "additional_capabilities" {
  type = object({
    ultra_ssd_enabled = bool
  })
  default     = null
  description = <<-EOT
  object({
    ultra_ssd_enabled = "(Optional) Should the capacity to enable Data Disks of the `UltraSSD_LRS` storage account type be supported on this Virtual Machine? Defaults to `false`."
  })
  EOT
}


variable "rolling_upgrade_policy" {
  type    = any
  default = []
}


variable "spot_restore" {
  type        = any
  default     = []
  description = <<-EOT
  enabled - (Optional) Should the Spot-Try-Restore feature be enabled? The Spot-Try-Restore feature will attempt to automatically restore the evicted Spot Virtual Machine Scale Set VM instances opportunistically based on capacity availability and pricing constraints. Possible values are true or false. Defaults to false. Changing this forces a new resource to be created.
timeout - (Optional) The length of time that the Virtual Machine Scale Set should attempt to restore the Spot VM instances which have been evicted. The time duration should be between 15 minutes and 120 minutes (inclusive). The time duration should be specified in the ISO 8601 format. Defaults to 90 minutes (e.g. PT1H30M). Changing this forces a new resource to be created.
EOT
}

variable "scale_in" {
  type        = any
  default     = []
  description = <<-EOT
  rule - (Optional) The scale-in policy rule that decides which virtual machines are chosen for removal when a Virtual Machine Scale Set is scaled in. Possible values for the scale-in policy rules are Default, NewestVM and OldestVM, defaults to Default. For more information about scale in policy, please refer to this doc.
  force_deletion_enabled - (Optional) Should the virtual machines chosen for removal be force deleted when the virtual machine scale set is being scaled-in? Possible values are true or false. Defaults to false.
  EOT
}

variable "automatic_instance_repair" {
  type        = any
  default     = {}
  description = <<-EOT
    automatic_os_upgrade_policy - (Optional) An automatic_os_upgrade_policy block as defined below. This can only be specified when upgrade_mode is set to either Automatic or Rolling.
    automatic_instance_repair - (Optional) An automatic_instance_repair block as defined below. To enable the automatic instance repair, this Virtual Machine Scale Set must have a valid health_probe_id or an Application Health Extension.
    EOT
}


variable "create_autoscale_setting"{
  type = bool
  default = false
}
variable "autoscale_setting_profile"{
  type = any
  default = {}
}
variable "notification"{
  type = any
  default = {}
}


variable "application_type"{
  type = string
  default = "other" 
}
variable "metrics_retention_in_days"{
  type = number
  default = 30
}
variable "log_analytics_workspace_id"{
  type = string
  default = null
}