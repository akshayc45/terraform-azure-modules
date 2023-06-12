resource "tls_private_key" "rsa" {
  count     = var.virtual_machine_scale_set.disable_password_authentication ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

##
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.virtual_machine_scale_set.name
  location            = var.virtual_machine_scale_set.location
  resource_group_name = var.virtual_machine_scale_set.resource_group_name
  admin_username      = var.virtual_machine_scale_set.admin_username
  instances           = var.virtual_machine_scale_set.instances #(Optional) The number of Virtual Machines in the Scale Set. Defaults to 0.
  sku                 = var.virtual_machine_scale_set.sku
  admin_password      = var.virtual_machine_scale_set.disable_password_authentication == false ? var.virtual_machine_scale_set.admin_password : null
  #or
  dynamic "admin_ssh_key" {
    for_each = var.virtual_machine_scale_set.disable_password_authentication ? [1] : []
    content {
      username   = var.virtual_machine_scale_set.admin_username
      public_key = try(file(var.virtual_machine_scale_set.admin_ssh_key_data), tls_private_key.rsa[0].public_key_openssh)
    }
  }

  capacity_reservation_group_id = try(var.virtual_machine_scale_set.capacity_reservation_group_id, null) #null#(Optional) Specifies the ID of the Capacity Reservation Group which the Virtual Machine Scale Set should be allocated to. Changing this forces a new resource to be created.
  #NOTE:
  #capacity_reservation_group_id cannot be used with proximity_placement_group_id
  #NOTE:
  #single_placement_group must be set to false when capacity_reservation_group_id is specified.

  computer_name_prefix            = var.virtual_machine_scale_set.computer_name_prefix
  custom_data                     = base64encode(var.virtual_machine_scale_set.custom_data)
  disable_password_authentication = var.virtual_machine_scale_set.disable_password_authentication #null#(Optional) Should Password Authentication be disabled on this Virtual Machine Scale Set? Defaults to true.

  do_not_run_extensions_on_overprovisioned_machines = try(var.virtual_machine_scale_set.do_not_run_extensions_on_overprovisioned_machines, null) #null#(Optional) Should Virtual Machine Extensions be run on Overprovisioned Virtual Machines in the Scale Set? Defaults to false.
  edge_zone                                         = try(var.virtual_machine_scale_set.edge_zone, null)                                         #null#(Optional) Specifies the Edge Zone within the Azure Region where this Linux Virtual Machine Scale Set should exist. Changing this forces a new Linux Virtual Machine Scale Set to be created.
  encryption_at_host_enabled                        = try(var.virtual_machine_scale_set.encryption_at_host_enabled, null)                        #null#(Optional) Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?

  extension_operations_enabled = try(var.virtual_machine_scale_set.extension_operations_enabled, null)
  extensions_time_budget       = try(var.virtual_machine_scale_set.extensions_time_budget, null)
  eviction_policy              = try(var.virtual_machine_scale_set.eviction_policy, null)

  dynamic "gallery_application" {
    for_each = var.gallery_application
    content {
      version_id             = gallery_application.value.version_id
      configuration_blob_uri = gallery_application.value.configuration_blob_uri
      order                  = gallery_application.value.order
      tag                    = gallery_application.value.tag
    }
  }

  health_probe_id = try(var.virtual_machine_scale_set.health_probe_id, null) #null#(Optional) The ID of a Load Balancer Probe which should be used to determine the health of an instance. This is Required and can only be specified when upgrade_mode is set to Automatic or Rolling.
  host_group_id   = try(var.virtual_machine_scale_set.host_group_id, null)   #null#(Optional) Specifies the ID of the dedicated host group that the virtual machine scale set resides in. Changing this forces a new resource to be created.
  #make changes required

  dynamic "identity" {
    for_each = var.identity
    content {
      type         = var.identity.type
      identity_ids = var.identity.identity_ids
    }
  }

  max_bid_price = try(var.virtual_machine_scale_set.max_bid_price, null) #null#(Optional) The maximum price you're willing to pay for each Virtual Machine in this Scale Set, in US Dollars; which must be greater than the current spot price. If this bid price falls below the current spot price the Virtual Machines in the Scale Set will be evicted using the eviction_policy. Defaults to -1, which means that each Virtual Machine in this Scale Set should not be evicted for price reasons.

  overprovision = try(var.virtual_machine_scale_set.overprovision, null) #null#(Optional) Should Azure over-provision Virtual Machines in this Scale Set? This means that multiple Virtual Machines will be provisioned and Azure will keep the instances which become available first - which improves provisioning success rates and improves deployment time. You're not billed for these over-provisioned VM's and they don't count towards the Subscription Quota. Defaults to true.

  dynamic "plan" {
    for_each = var.plan == null ? [] : ["plan"]
    content {
      name      = var.plan.name
      product   = var.plan.product
      publisher = var.plan.publisher
    }
  }
  platform_fault_domain_count = try(var.virtual_machine_scale_set.platform_fault_domain_count, null) #null#(Optional) Specifies the number of fault domains that are used by this Linux Virtual Machine Scale Set. Changing this forces a new resource to be created.

  priority                     = try(var.virtual_machine_scale_set.priority, null)                     #null
  provision_vm_agent           = try(var.virtual_machine_scale_set.provision_vm_agent, null)           #null
  proximity_placement_group_id = try(var.virtual_machine_scale_set.proximity_placement_group_id, null) #null

  dynamic "rolling_upgrade_policy" {
    for_each = var.rolling_upgrade_policy
    content {
      cross_zone_upgrades_enabled             = try(rolling_upgrade_policy.value.cross_zone_upgrades_enabled, null)
      max_batch_instance_percent              = try(rolling_upgrade_policy.value.max_batch_instance_percent, null)
      max_unhealthy_instance_percent          = try(rolling_upgrade_policy.value.max_unhealthy_instance_percent, null)
      max_unhealthy_upgraded_instance_percent = try(rolling_upgrade_policy.value.max_unhealthy_upgraded_instance_percent, null)
      pause_time_between_batches              = try(rolling_upgrade_policy.value.pause_time_between_batches, null)
      prioritize_unhealthy_instances_enabled  = try(rolling_upgrade_policy.value.prioritize_unhealthy_instances_enabled, null)
    }
  }

  dynamic "scale_in" {
    for_each = var.scale_in
    content {
      rule                   = var.scale_in.rule
      force_deletion_enabled = var.scale_in.force_deletion_enabled
    }
  }

  dynamic "secret" {
    for_each = toset(var.secrets)

    content {
      key_vault_id = secret.value.key_vault_id

      dynamic "certificate" {
        for_each = secret.value.certificate
        content {
          url = certificate.value.url
        }
      }
    }
  }
  secure_boot_enabled    = try(var.virtual_machine_scale_set.secure_boot_enabled, null)    #(Optional) Specifies whether secure boot should be enabled on the virtual machine. Changing this forces a new resource to be created.
  single_placement_group = try(var.virtual_machine_scale_set.single_placement_group, true) #(Optional) Should this Virtual Machine Scale Set be limited to a Single Placement Group, which means the number of instances will be capped at 100 Virtual Machines. Defaults to true.
  source_image_id        = try(var.virtual_machine_scale_set.source_image_id, null)

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }
  # NOTE:
  # One of either source_image_id or source_image_reference must be set.
  dynamic "spot_restore" {
    for_each = var.spot_restore
    content {
      enabled = spot_restore.value.enable
      timeout = spot_restore.value.enable
    }
  }

  tags = merge({ "ResourceGroup" = var.virtual_machine_scale_set.name }, try(var.virtual_machine_scale_set.tags, null)) #(Optional) A mapping of tags which should be assigned to this Virtual Machine Scale Set.

  dynamic "termination_notification" {
    for_each = var.termination_notification == null ? [] : ["termination_notification"]
    content {
      enabled = var.termination_notification.enabled
      timeout = var.termination_notification.timeout
    }
  }
  upgrade_mode = try(var.virtual_machine_scale_set.upgrade_mode, "Manual") #(Optional) Specifies how Upgrades (e.g. changing the Image/SKU) should be performed to Virtual Machine Instances. Possible values are Automatic, Manual and Rolling. Defaults to Manual. Changing this forces a new resource to be created.
  user_data    = try(var.virtual_machine_scale_set.user_data, null)        #(Optional) The Base64-Encoded User Data which should be used for this Virtual Machine Scale Set.
  vtpm_enabled = try(var.virtual_machine_scale_set.vtpm_enabled, null)     #(Optional) Specifies whether vTPM should be enabled on the virtual machine. Changing this forces a new resource to be created.
  zone_balance = try(var.virtual_machine_scale_set.zone_balance, false)    #(Optional) Should the Virtual Machines in this Scale Set be strictly evenly distributed across Availability Zones? Defaults to false. Changing this forces a new resource to be created.
  zones        = var.virtual_machine_scale_set.zones                       #(Optional) Specifies a list of Availability Zones in which this Linux Virtual Machine Scale Set should be located. Changing this forces a new Linux Virtual Machine Scale Set to be created.

  os_disk {
    caching                          = try(var.os_disk.caching, null)
    storage_account_type             = try(var.os_disk.storage_account_type, null)
    disk_encryption_set_id           = try(var.os_disk.disk_encryption_set_id, null)
    disk_size_gb                     = try(var.os_disk.disk_size_gb, null)
    secure_vm_disk_encryption_set_id = try(var.os_disk.secure_vm_disk_encryption_set_id, null)
    #secure_vm_disk_encryption_set_id can only be specified when security_encryption_type is set to DiskWithVMGuestState.
    security_encryption_type  = try(var.os_disk.security_encryption_type, null)
    write_accelerator_enabled = try(var.os_disk.write_accelerator_enabled, null)
    dynamic "diff_disk_settings" {
      for_each = lookup(var.os_disk, "diff_disk_settings", [])
      content {
        option    = diff_disk_settings.value.option
        placement = diff_disk_settings.value.placement
      }
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interface
    content {
      name = network_interface.value.name
      ###
      dynamic "ip_configuration" {
        for_each = network_interface.value.ip_configuration #backend_http_settings.value.
        content {
          name                                         = try(ip_configuration.value["name"], null)
          application_gateway_backend_address_pool_ids = try(ip_configuration.value["application_gateway_backend_address_pool_ids"], null)
          application_security_group_ids               = try(ip_configuration.value["application_security_group_ids"], null)
          load_balancer_backend_address_pool_ids       = try(ip_configuration.value["load_balancer_backend_address_pool_ids"], null)
          load_balancer_inbound_nat_rules_ids          = try(ip_configuration.value["load_balancer_inbound_nat_rules_ids"], null)
          primary                                      = try(ip_configuration.value["primary"], null)
          dynamic "public_ip_address" {
            for_each = try(ip_configuration.value.public_ip_address, {}) #ip_configuration.value.public_ip_address
            content {
              name                    = public_ip_address.value.name
              domain_name_label       = try(public_ip_address.value.domain_name_label, null)
              idle_timeout_in_minutes = try(public_ip_address.value.idle_timeout_in_minutes, null)
              public_ip_prefix_id     = try(public_ip_address.value.public_ip_prefix_id, null)
              version                 = try(public_ip_address.value.version, null)
            }
          }
          subnet_id = try(ip_configuration.value["subnet_id"], null)
          version   = try(ip_configuration.value["version"], "IPv4")
        }
      }
      dns_servers                   = try(network_interface.value.dns_servers, null)
      enable_accelerated_networking = try(network_interface.value.enable_accelerated_networking, null)
      enable_ip_forwarding          = try(network_interface.value.enable_ip_forwarding, null)
      network_security_group_id     = try(network_interface.value.network_security_group_id, null)
      primary                       = try(network_interface.value.primary, null)

    }
  }

  dynamic "extension" {
    for_each = var.extension
    content {
      name                       = extension.value.name
      publisher                  = extension.value
      type                       = extension.value.type
      type_handler_version       = extension.value.type_handler_version
      auto_upgrade_minor_version = try(extension.value.auto_upgrade_minor_version, null)
      automatic_upgrade_enabled  = try(extension.value.automatic_upgrade_enabled, null)
      force_update_tag           = try(extension.value.force_update_tag, null)
      protected_settings         = try(extension.value.protected_settings, null)
      provision_after_extensions = try(extension.value.provision_after_extensions, null)
      settings                   = try(extension.value.settings, null)
      dynamic "protected_settings_from_key_vault" {
        for_each = lookup(extension.value, "protected_settings_from_key_vault", [])
        content {
          secret_url      = protected_settings_from_key_vault.value.secret_url
          source_vault_id = protected_settings_from_key_vault.value.source_vault_id
        }
      }

    }
  }

  dynamic "data_disk" {
    for_each = var.data_disk
    content {
      name                           = try(data_disk.value.name, null)
      caching                        = try(data_disk.value.caching, null)
      create_option                  = try(data_disk.value.create_option, null)
      disk_size_gb                   = data_disk.value.disk_size_gb
      lun                            = data_disk.value.lun
      storage_account_type           = data_disk.value.storage_account_type
      disk_encryption_set_id         = try(data_disk.value.disk_encryption_set_id, null)
      ultra_ssd_disk_iops_read_write = try(data_disk.value.ultra_ssd_disk_iops_read_write, null)
      ultra_ssd_disk_mbps_read_write = try(data_disk.value.ultra_ssd_disk_mbps_read_write, null)
      write_accelerator_enabled      = try(data_disk.value.write_accelerator_enabled, null)
    }
  }

  dynamic "boot_diagnostics" {
    for_each = try(var.termination_notification.enable_boot_diagnostics, false) == true ? [1] : []
    content {
      storage_account_uri = var.termination_notification.storage_account_uri
    }
  }
  #make changes required
  dynamic "automatic_instance_repair" {
    for_each = var.automatic_instance_repair
    content {
      enabled      = var.automatic_instance_repair.enabled
      grace_period = var.automatic_instance_repair.enabled
    }
  }

  dynamic "additional_capabilities" {
    for_each = var.additional_capabilities == null ? [] : ["additional_capabilities"]

    content {
      ultra_ssd_enabled = var.additional_capabilities.ultra_ssd_enabled
    }
  }
  depends_on = [ azurerm_application_gateway.main, azurerm_lb.azlb ]
}

#-------------autoscale setting

resource "azurerm_monitor_autoscale_setting" "this" {
  count = var.create_autoscale_setting ? 1 : 0
  name                = "${var.virtual_machine_scale_set.name}-autoscale_setting"
  resource_group_name = local.resource_group_name
  location            = local.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss.id
  depends_on = [azurerm_linux_virtual_machine_scale_set.vmss]#azurerm_application_insights.this

  dynamic "profile" {
    for_each = var.autoscale_setting_profile
    content {
    name = profile.key
    capacity {
      #for_each = lookup(profile.value, "capacity", [])
      default = profile.value.default_capacity
      minimum = profile.value.minimum_capacity
      maximum = profile.value.maximum_capacity
    }

    dynamic "rule" {
      for_each = lookup(profile.value, "rule", {})
      content {
        metric_trigger {
          metric_name        = rule.key
          metric_resource_id = rule.key == "Percentage CPU" ? azurerm_linux_virtual_machine_scale_set.vmss.id : azurerm_application_insights.insights.id
          metric_namespace   = try(rule.value.metric_namespace, "Azure.ApplicationInsights")
          operator           = rule.value.operator#"GreaterThanOrEqual"
          threshold          = rule.value.threshold

          statistic        = rule.value.statistic#var.scaleout_statistic
          time_aggregation = rule.value.time_aggregation#var.scaleout_time_aggregation
          time_grain       = try("PT${rule.value.time_grain}", "PT1M") # PT1M means: Period of Time 1 Minute
          time_window      = "PT${rule.value.time_window}"
        }

        scale_action {
          direction = rule.value.direction
          value     = rule.value.scale_value
          type      = rule.value.scale_type
          cooldown  = "PT${rule.value.cooldown_time}"
        }
      }
    }

	
dynamic "recurrence" {
  for_each = lookup(var.autoscale_setting_profile, "recurrence", [])
  content {
	  days = recurrence.value.recurrence_days == "ALL" ? ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"] : try(profile.value.recurrence_days, null)
		#timeZone ="UTC"
		hours = try(recurrence.value.recurrence_days, [0])
		minutes = try(recurrence.value.recurrence_days, [0]) 
    }
  }
  }
  }

dynamic "notification" {
  for_each = var.notification
  content {
    dynamic "email" {
      for_each = notification.key == "email" ? [notification.value.email] : []
      content {
      send_to_subscription_administrator    = email.value.subscription_administrator
      send_to_subscription_co_administrator = email.value.subscription_co_administrator
      custom_emails                         = email.value.custom_emails
    }
    }
    dynamic "webhook" {
      for_each = notification.key == "webhook" ? [notification.value.webhook] : [] 
      content {
      service_uri    = webhook.value.service_uri
      properties  = webhook.value.properties
    }
    }
  }  
  #depends_on = [azurerm_application_insights.this]
}
}

resource "azurerm_application_insights" "insights" {
  name                = "${var.virtual_machine_scale_set.name}-insights"
  location            = local.location
  resource_group_name = local.resource_group_name
  application_type    = var.application_type#"other"
  retention_in_days   = var.metrics_retention_in_days
  tags = merge(tomap({
         ResourceName = "${var.virtual_machine_scale_set.name}-insights" }),
         var.tags,
)
}

resource "azurerm_monitor_diagnostic_setting" "monitor-diag" {
  count = var.log_analytics_workspace_id != null ? 1 : 0
  name  = "${var.virtual_machine_scale_set.name}-diag-setting"

  target_resource_id         = azurerm_linux_virtual_machine_scale_set.vmss.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}

# locals {
#   scaleout_cooldown_minutes = "${var.scaleout_cooldown_minutes % 60}M"
#   scaleout_cooldown_hours   = "${floor(var.scaleout_cooldown_minutes / 60) % 24}H"
#   scaleout_cooldown_days    = "${floor(var.scaleout_cooldown_minutes / (60 * 24))}D"
#   scaleout_cooldown_t       = "T${local.scaleout_cooldown_hours != "0H" ? local.scaleout_cooldown_hours : ""}${local.scaleout_cooldown_minutes != "0M" ? local.scaleout_cooldown_minutes : ""}"
#   scaleout_cooldown         = "P${local.scaleout_cooldown_days != "0D" ? local.scaleout_cooldown_days : ""}${local.scaleout_cooldown_t != "T" ? local.scaleout_cooldown_t : ""}"

#   scaleout_window_minutes = "${var.scaleout_window_minutes % 60}M"
#   scaleout_window_hours   = "${floor(var.scaleout_window_minutes / 60) % 24}H"
#   scaleout_window_days    = "${floor(var.scaleout_window_minutes / (60 * 24))}D"
#   scaleout_window_t       = "T${local.scaleout_window_hours != "0H" ? local.scaleout_window_hours : ""}${local.scaleout_window_minutes != "0M" ? local.scaleout_window_minutes : ""}"
#   scaleout_window         = "P${local.scaleout_window_days != "0D" ? local.scaleout_window_days : ""}${local.scaleout_window_t != "T" ? local.scaleout_window_t : ""}"

#   scalein_cooldown_minutes = "${var.scalein_cooldown_minutes % 60}M"
#   scalein_cooldown_hours   = "${floor(var.scalein_cooldown_minutes / 60) % 24}H"
#   scalein_cooldown_days    = "${floor(var.scalein_cooldown_minutes / (60 * 24))}D"
#   scalein_cooldown_t       = "T${local.scalein_cooldown_hours != "0H" ? local.scalein_cooldown_hours : ""}${local.scalein_cooldown_minutes != "0M" ? local.scalein_cooldown_minutes : ""}"
#   scalein_cooldown         = "P${local.scalein_cooldown_days != "0D" ? local.scalein_cooldown_days : ""}${local.scalein_cooldown_t != "T" ? local.scalein_cooldown_t : ""}"

#   scalein_window_minutes = "${var.scalein_window_minutes % 60}M"
#   scalein_window_hours   = "${floor(var.scalein_window_minutes / 60) % 24}H"
#   scalein_window_days    = "${floor(var.scalein_window_minutes / (60 * 24))}D"
#   scalein_window_t       = "T${local.scalein_window_hours != "0H" ? local.scalein_window_hours : ""}${local.scalein_window_minutes != "0M" ? local.scalein_window_minutes : ""}"
#   scalein_window         = "P${local.scalein_window_days != "0D" ? local.scalein_window_days : ""}${local.scalein_window_t != "T" ? local.scalein_window_t : ""}"

  
# }
