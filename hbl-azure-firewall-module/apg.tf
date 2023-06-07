#---------------------------
# Local declarations
#---------------------------
locals {
  frontend_port_name             = "${var.app_gateway_name}-feport"
  frontend_ip_configuration_name = "${var.app_gateway_name}-feip"
  gateway_ip_configuration_name  = "${var.app_gateway_name}-gwipc"
  WAF_name                       = "${var.app_gateway_name}-waf-policy"

  resource_group_name = var.resource_group_name
  location            = var.location
}

data "azurerm_resource_group" "rgrp" {
  #count = var.create_resource_group ? 1 : 0
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.vnet_resource_group_name == null ? local.resource_group_name : var.vnet_resource_group_name
}

data "azurerm_subnet" "snet" {
  count = var.subnet_name == null ? 1 :0
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

data "azurerm_log_analytics_workspace" "logws" {
  count               = var.log_analytics_workspace_name != null ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = local.resource_group_name
}

data "azurerm_storage_account" "storeacc" {
  count               = var.storage_account_name != null ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = local.resource_group_name
}

#-----------------------------------
# WAF policy
#----------------------------------
resource "azurerm_web_application_firewall_policy" "waf_policy" {
  #for_each = var.waf_policies
  name                = local.WAF_name
  resource_group_name = local.resource_group_name
  location            = local.location
  tags = merge(tomap({
    ResourceName = local.WAF_name }),
    var.waf_policy_tags,
  )

  policy_settings {
    enabled                     = try(var.policy_settings.enable, true)
    file_upload_limit_in_mb     = try(var.policy_settings.file_upload_limit_in_mb, 100)
    max_request_body_size_in_kb = try(var.policy_settings.max_request_body_size_in_kb, 128)
    mode                        = try(var.policy_settings.mode, "Detection")
    request_body_check          = try(var.policy_settings.request_body_check, true)
  }

  dynamic "managed_rules" {
    for_each = var.managed_rules #var.managed_rules
    content {

      dynamic "managed_rule_set" {
        for_each = lookup(managed_rules.value, "managed_rule_set", [])
        content {
          type    = lookup(managed_rule_set.value, "type", null)    #"OWASP"
          version = lookup(managed_rule_set.value, "version", null) #"3.1"
        }
      }
      dynamic "exclusion" {
        for_each = var.managed_policies_exclusions
        content {
          match_variable          = exclusion.value.match_variable
          selector                = exclusion.value.selector
          selector_match_operator = exclusion.value.selector_match_operator
        }
      }
    }
  }
  dynamic "custom_rules" {
    for_each = var.custom_policies
    content {
      name      = custom_rules.value.name
      priority  = custom_rules.value.priority
      rule_type = custom_rules.value.rule_type
      action    = custom_rules.value.action

      dynamic "match_conditions" {
        for_each = lookup(custom_rules.value, "match_conditions", [])
        content {
          dynamic "match_variables" {
            for_each = lookup(match_conditions.value, "match_variables", [])
            content {
              variable_name = match_variables.value.match_variable
              selector      = match_variables.value.selector
            }
          }

          operator           = match_conditions.value.operator
          negation_condition = match_conditions.value.negation_condition
          match_values       = match_conditions.value.match_values
        }
      }
    }
  }
}


#-----------------------------------
# Public IP for application gateway
#-----------------------------------
resource "azurerm_public_ip" "pip" {
  count               = var.creatpip ? 1 : 0
  name                = lower("${var.app_gateway_name}-gw-pip")
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = var.sku.tier == "Standard" ? "Dynamic" : "Static"
  sku                 = var.sku.tier == "Standard" ? "Basic" : "Standard"
  domain_name_label   = try(var.domain_name_label, null)
  tags                = merge({ "ResourceName" = lower("${var.app_gateway_name}-gw-pip") }, var.tags, )
}

#----------------------------------------------
# Application Gateway with all optional blocks
#----------------------------------------------
resource "azurerm_application_gateway" "main" {
  count                             = var.creat_apg ? 1 : 0
  name                              = lower("${var.app_gateway_name}-appgw")
  resource_group_name               = local.resource_group_name
  location                          = local.location
  enable_http2                      = var.enable_http2
  zones                             = var.zones
  firewall_policy_id                = try(azurerm_web_application_firewall_policy.waf_policy.id, null)
  fips_enabled                      = var.isfips_enabled
  force_firewall_policy_association = var.force_firewall_policy_association
  tags                              = merge({ "ResourceName" = lower("appgw-${var.app_gateway_name}-${local.location}") }, var.tags, )

  sku {
    name     = var.sku.name
    tier     = var.sku.tier
    capacity = var.autoscale_configuration == null ? var.sku.capacity : null
  }

  dynamic "autoscale_configuration" {
    for_each = var.autoscale_configuration != null ? [var.autoscale_configuration] : []
    content {
      min_capacity = lookup(autoscale_configuration.value, "min_capacity")
      max_capacity = lookup(autoscale_configuration.value, "max_capacity")
    }
  }

  dynamic "gateway_ip_configuration" {
    for_each = var.gateway_ip_configuration
    content {
      name      = gateway_ip_configuration.value.name
      subnet_id = try(data.azurerm_subnet.snet.id, gateway_ip_configuration.value.subnet_id)
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configuration
    content {
      name                          = local.frontend_ip_configuration_name
      public_ip_address_id          = try(azurerm_public_ip.pip[0].id, frontend_ip_configuration.value.public_ip_address_id)
      private_ip_address            = try(frontend_ip_configuration.value.private_ip_address, null)
      private_ip_address_allocation = try(frontend_ip_configuration.value.private_ip_address_allocation, null)
      subnet_id                     = var.creatpip ? null : try(data.azurerm_subnet.snet.id, null)
    }
  }

  dynamic "frontend_port" {
    for_each = var.frontend_port
    content {
      name = try(frontend_port.value.port == 80 ? "${local.frontend_port_name}-80" : "${local.frontend_port_name}-443", frontend_port.value.name)
      port = frontend_port.value.port
    }
  }



  #----------------------------------------------------------
  # Backend Address Pool Configuration (Required)
  #----------------------------------------------------------
  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = backend_address_pool.value.name
      fqdns        = try(backend_address_pool.value.fqdns, null)
      ip_addresses = try(backend_address_pool.value.ip_addresses, null)
    }
  }

  #----------------------------------------------------------
  # Backend HTTP Settings (Required)
  #----------------------------------------------------------
  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                                = backend_http_settings.value.name
      cookie_based_affinity               = lookup(backend_http_settings.value, "cookie_based_affinity", "Disabled")
      affinity_cookie_name                = lookup(backend_http_settings.value, "affinity_cookie_name", null)
      path                                = lookup(backend_http_settings.value, "path", "/")
      port                                = backend_http_settings.value.port
      probe_name                          = lookup(backend_http_settings.value, "probe_name", null)
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = lookup(backend_http_settings.value, "request_timeout", 30)
      host_name                           = backend_http_settings.value.pick_host_name_from_backend_address == false ? backend_http_settings.value.host_name : null
      pick_host_name_from_backend_address = lookup(backend_http_settings.value, "pick_host_name_from_backend_address", false)

      dynamic "authentication_certificate" {
        for_each = lookup(backend_http_settings.value, "authentication_certificate", [])
        content {
          name = authentication_certificate.value.name
        }
      }

      trusted_root_certificate_names = lookup(backend_http_settings.value, "trusted_root_certificate_names", null)

      dynamic "connection_draining" {
        for_each = lookup(backend_http_settings.value, "connection_draining", [])
        content {
          enabled           = connection_draining.value.enable_connection_draining
          drain_timeout_sec = connection_draining.value.drain_timeout_sec
        }
      }
    }
  }

  #----------------------------------------------------------
  # HTTP Listener Configuration (Required)
  #----------------------------------------------------------
  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = local.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.ssl_certificate_name == null ? "${local.frontend_port_name}-80" : "${local.frontend_port_name}-443"
      host_name                      = lookup(http_listener.value, "host_name", null)
      host_names                     = lookup(http_listener.value, "host_names", null)
      protocol                       = http_listener.value.ssl_certificate_name == null ? "Http" : "Https"
      require_sni                    = http_listener.value.ssl_certificate_name != null ? http_listener.value.require_sni : null
      ssl_certificate_name           = http_listener.value.ssl_certificate_name
      firewall_policy_id             = http_listener.value.firewall_policy_id
      ssl_profile_name               = http_listener.value.ssl_profile_name

      dynamic "custom_error_configuration" {
        for_each = http_listener.value.custom_error_configuration != null ? lookup(http_listener.value, "custom_error_configuration", {}) : []
        content {
          custom_error_page_url = lookup(custom_error_configuration.value, "custom_error_page_url", null)
          status_code           = lookup(custom_error_configuration.value, "status_code", null)
        }
      }
    }
  }

  dynamic "global" {
    for_each = var.global
    content {
      request_buffering_enabled  = try(global.value.request_buffering_enabled, false)
      response_buffering_enabled = try(global.value.response_buffering_enabled, false)
    }
  }
  #----------------------------------------------------------
  # Request routing rules Configuration (Required)
  #----------------------------------------------------------
  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules
    content {
      name                        = request_routing_rule.value.name
      rule_type                   = lookup(request_routing_rule.value, "rule_type", "Basic")
      http_listener_name          = request_routing_rule.value.http_listener_name
      backend_address_pool_name   = try(request_routing_rule.value.backend_address_pool_name, null)
      backend_http_settings_name  = try(request_routing_rule.value.backend_http_settings_name, null)
      redirect_configuration_name = lookup(request_routing_rule.value, "redirect_configuration_name", null)
      rewrite_rule_set_name       = lookup(request_routing_rule.value, "rewrite_rule_set_name", null)
      url_path_map_name           = lookup(request_routing_rule.value, "url_path_map_name", null)
      priority                    = request_routing_rule.value.priority
    }
  }

  #---------------------------------------------------------------
  # Identity block Configuration (Optional)
  # A list with a single user managed identity id to be assigned
  #---------------------------------------------------------------
  dynamic "identity" {
    for_each = var.identity_ids != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  #----------------------------------------------------------
  # Authentication SSL Certificate Configuration (Optional)
  #----------------------------------------------------------
  dynamic "authentication_certificate" {
    for_each = var.authentication_certificates
    content {
      name = authentication_certificate.value.name
      data = filebase64(authentication_certificate.value.data)
    }
  }

  #----------------------------------------------------------
  # Trusted Root SSL Certificate Configuration (Optional)
  #----------------------------------------------------------
  dynamic "trusted_root_certificate" {
    for_each = var.trusted_root_certificates
    content {
      name = trusted_root_certificate.value.name
      data = filebase64(trusted_root_certificate.value.data)
    }
  }

  #----------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # SSL Policy for Application Gateway (Optional)
  # Application Gateway has three predefined security policies to get the appropriate level of security
  # AppGwSslPolicy20150501 - MinProtocolVersion(TLSv1_0), AppGwSslPolicy20170401 - MinProtocolVersion(TLSv1_1), AppGwSslPolicy20170401S - MinProtocolVersion(TLSv1_2)
  #----------------------------------------------------------------------------------------------------------------------------------------------------------------------
  dynamic "ssl_policy" {
    for_each = var.ssl_policy != null ? [var.ssl_policy] : []
    content {
      disabled_protocols   = var.ssl_policy.policy_type == null && var.ssl_policy.policy_name == null ? var.ssl_policy.disabled_protocols : null
      policy_type          = lookup(var.ssl_policy, "policy_type", "Predefined")
      policy_name          = var.ssl_policy.policy_type == "Predefined" ? var.ssl_policy.policy_name : null
      cipher_suites        = var.ssl_policy.policy_type == "Custom" ? var.ssl_policy.cipher_suites : null
      min_protocol_version = var.ssl_policy.min_protocol_version
    }
  }

  #----------------------------------------------------------
  # SSL Certificate (.pfx) Configuration (Optional)
  #----------------------------------------------------------
  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates
    content {
      name                = ssl_certificate.value.name
      data                = ssl_certificate.value.key_vault_secret_id == null ? filebase64(ssl_certificate.value.data) : null
      password            = ssl_certificate.value.key_vault_secret_id == null ? ssl_certificate.value.password : null
      key_vault_secret_id = lookup(ssl_certificate.value, "key_vault_secret_id", null)
    }
  }

  #----------------------------------------------------------
  # Health Probe (Optional)
  #----------------------------------------------------------
  dynamic "probe" {
    for_each = var.health_probes
    content {
      name                                      = probe.key
      host                                      = lookup(probe.value, "host", "127.0.0.1")
      interval                                  = lookup(probe.value, "interval", 30)
      protocol                                  = probe.value.port == 443 ? "Https" : "Http"
      path                                      = lookup(probe.value, "path", "/")
      timeout                                   = lookup(probe.value, "timeout", 30)
      unhealthy_threshold                       = lookup(probe.value, "unhealthy_threshold", 3)
      port                                      = lookup(probe.value, "port", 443)
      pick_host_name_from_backend_http_settings = lookup(probe.value, "pick_host_name_from_backend_http_settings", false)
      minimum_servers                           = lookup(probe.value, "minimum_servers", 0)

      dynamic "match" {
        for_each = lookup(probe.value, "match", [])
        content {
          body        = match.value.body
          status_code = match.value.status_code
        }
      }
    }
  }

  #----------------------------------------------------------
  # URL Path Mappings (Optional)
  #----------------------------------------------------------
  dynamic "url_path_map" {
    for_each = var.url_path_maps
    content {
      name                                = url_path_map.value.name
      default_backend_address_pool_name   = url_path_map.value.default_redirect_configuration_name == null ? url_path_map.value.default_backend_address_pool_name : null
      default_backend_http_settings_name  = url_path_map.value.default_redirect_configuration_name == null ? url_path_map.value.default_backend_http_settings_name : null
      default_redirect_configuration_name = lookup(url_path_map.value, "default_redirect_configuration_name", null)
      default_rewrite_rule_set_name       = lookup(url_path_map.value, "default_rewrite_rule_set_name", null)

      dynamic "path_rule" {
        for_each = lookup(url_path_map.value, "path_rules")
        content {
          name                        = path_rule.value.name
          backend_address_pool_name   = path_rule.value.backend_address_pool_name
          backend_http_settings_name  = path_rule.value.backend_http_settings_name
          paths                       = flatten(path_rule.value.paths)
          redirect_configuration_name = lookup(path_rule.value, "redirect_configuration_name", null)
          rewrite_rule_set_name       = lookup(path_rule.value, "rewrite_rule_set_name", null)
          firewall_policy_id          = lookup(path_rule.value, "firewall_policy_id", null)
        }
      }
    }
  }

  #----------------------------------------------------------
  # Redirect Configuration (Optional)
  #----------------------------------------------------------
  dynamic "redirect_configuration" {
    for_each = var.redirect_configuration
    content {
      name                 = lookup(redirect_configuration.value, "name", null)
      redirect_type        = lookup(redirect_configuration.value, "redirect_type", "Permanent")
      target_listener_name = lookup(redirect_configuration.value, "target_listener_name", null)
      target_url           = lookup(redirect_configuration.value, "target_url", null)
      include_path         = lookup(redirect_configuration.value, "include_path", "true")
      include_query_string = lookup(redirect_configuration.value, "include_query_string", "true")
    }
  }

  #----------------------------------------------------------
  # Custom error configuration (Optional)
  #----------------------------------------------------------
  dynamic "custom_error_configuration" {
    for_each = var.custom_error_configuration
    content {
      custom_error_page_url = lookup(custom_error_configuration.value, "custom_error_page_url", null)
      status_code           = lookup(custom_error_configuration.value, "status_code", null)
    }
  }

  #----------------------------------------------------------
  # Rewrite Rules Set configuration (Optional)
  #----------------------------------------------------------
  dynamic "rewrite_rule_set" {
    for_each = var.rewrite_rule_set
    content {
      name = var.rewrite_rule_set.name

      dynamic "rewrite_rule" {
        for_each = lookup(var.rewrite_rule_set, "rewrite_rules", [])
        content {
          name          = rewrite_rule.value.name
          rule_sequence = rewrite_rule.value.rule_sequence

          dynamic "condition" {
            for_each = lookup(rewrite_rule_set.value, "condition", [])
            content {
              variable    = condition.value.variable
              pattern     = condition.value.pattern
              ignore_case = condition.value.ignore_case
              negate      = condition.value.negate
            }
          }

          dynamic "request_header_configuration" {
            for_each = lookup(rewrite_rule.value, "request_header_configuration", [])
            content {
              header_name  = request_header_configuration.value.header_name
              header_value = request_header_configuration.value.header_value
            }
          }

          dynamic "response_header_configuration" {
            for_each = lookup(rewrite_rule.value, "response_header_configuration", [])
            content {
              header_name  = response_header_configuration.value.header_name
              header_value = response_header_configuration.value.header_value
            }
          }

          dynamic "url" {
            for_each = lookup(rewrite_rule.value, "url", [])
            content {
              path         = url.value.path
              query_string = url.value.query_string
              reroute      = url.value.reroute
            }
          }
        }
      }
    }
  }

  #----------------------------------------------------------
  # Web application Firewall (WAF) configuration (Optional)
  # Tier to be either “WAF” or “WAF V2”
  #----------------------------------------------------------
  dynamic "waf_configuration" {
    for_each = var.waf_configuration != null ? [var.waf_configuration] : []
    content {
      enabled                  = lookup(waf_configuration.value, "enabled", true)
      firewall_mode            = lookup(waf_configuration.value, "firewall_mode", "Detection")
      rule_set_type            = lookup(waf_configuration.value, "rule_set_type", "OWASP")
      rule_set_version         = lookup(waf_configuration.value, "rule_set_version", "3.1")
      file_upload_limit_mb     = lookup(waf_configuration.value, "file_upload_limit_mb", 100)
      request_body_check       = lookup(waf_configuration.value, "request_body_check", true)
      max_request_body_size_kb = lookup(waf_configuration.value, "max_request_body_size_kb", 128)

      dynamic "disabled_rule_group" {
        for_each = waf_configuration.value.disabled_rule_group
        content {
          rule_group_name = disabled_rule_group.value.rule_group_name
          rules           = disabled_rule_group.value.rules
        }
      }

      dynamic "exclusion" {
        for_each = waf_configuration.value.exclusion
        content {
          match_variable          = exclusion.value.match_variable
          selector_match_operator = exclusion.value.selector_match_operator
          selector                = exclusion.value.selector
        }
      }
    }
  }

  dynamic "private_link_configuration" {
    for_each = var.private_link_configuration
    content {
      name = private_link_configuration.value.name
      dynamic "ip_configuration" {
        for_each = lookup(private_link_configuration.value, "ip_configuration", [])
        content {
          name                          = ip_configuration.value.name
          subnet_id                     = ip_configuration.value.subnet_id
          private_ip_address_allocation = ip_configuration.value.private_ip_address_allocation
          primary                       = ip_configuration.value.primary
          private_ip_address            = ip_configuration.value.private_ip_address
        }
      }
    }
  }

  dynamic "trusted_client_certificate" {
    for_each = var.trusted_client_certificate
    content {
      name = trusted_client_certificate.value.name
      data = trusted_client_certificate.value.data
    }
  }

  dynamic "ssl_profile" {
    for_each = var.ssl_profile
    content {
      name                             = ssl_profile.value.name
      trusted_client_certificate_names = ssl_profile.value.trusted_client_certificate_names
      verify_client_cert_issuer_dn     = ssl_profile.value.verify_client_cert_issuer_dn
      dynamic "ssl_policy" {
        for_each = lookup(ssl_profile.value, "ssl_policy", [])
        content {
          disabled_protocols = ssl_policy.value.disabled_protocols
          policy_type        = ssl_policy.value.policy_type
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

