resource "tls_private_key" "rsa" {
  count     = var.disable_password_authentication ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}
locals {
  os_type         = var.os_type
  virtual_machine = lower(local.os_type) == "linux" ? { id = try(azurerm_linux_virtual_machine.vm_linux[0].id, null) } : { id = try(azurerm_windows_virtual_machine.vm_windows[0].id, null) }
}
#############################################
##############  L I N U X V M  ##############
#############################################

data "azurerm_network_security_group" "nsg_ext" {
  count               = length(var.nsg_name)
  name                = element(var.nsg_name, count.index)
  resource_group_name = var.nsg_resource_group_name
}
data "azurerm_storage_account" "storeacc" {
  count               = var.storage_account_name != null ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = var.storage_account_resource_group_name
}
data "azurerm_subnet" "snet" {
  count                = var.subnet_name != null ? 1 : 0
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.snet_resource_group_name
}

data "azurerm_disk_encryption_set" "encrypt_disk" {
  count               = var.name_disk_encryption != null ? 1 : 0
  name                = var.name_disk_encryption
  resource_group_name = var.resource_group_name_disk_encryption
}
resource "azurerm_linux_virtual_machine" "vm_linux" {
  count = lower(local.os_type) == "linux" ? 1 : 0
  #for_each = lower(var.os_type) == "linux" ? var.linux_vm : {}

  admin_username                  = var.admin_username
  location                        = var.location
  name                            = var.name
  network_interface_ids           = try(var.network_interface_ids, null)
  resource_group_name             = var.resource_group_name
  size                            = var.size
  admin_password                  = var.admin_password
  allow_extension_operations      = var.allow_extension_operations
  availability_set_id             = var.availability_set_id
  capacity_reservation_group_id   = var.capacity_reservation_group_id
  computer_name                   = var.computer_name
  custom_data                     = var.custom_data
  dedicated_host_group_id         = var.dedicated_host_group_id
  dedicated_host_id               = var.dedicated_host_id
  disable_password_authentication = var.disable_password_authentication
  edge_zone                       = var.edge_zone
  encryption_at_host_enabled      = var.encryption_at_host_enabled
  eviction_policy                 = var.eviction_policy
  extensions_time_budget          = var.extensions_time_budget
  license_type                    = var.license_type
  max_bid_price                   = var.max_bid_price
  patch_assessment_mode           = var.patch_assessment_mode
  patch_mode                      = var.patch_mode
  platform_fault_domain           = var.platform_fault_domain
  priority                        = var.priority
  provision_vm_agent              = var.provision_vm_agent
  proximity_placement_group_id    = var.proximity_placement_group_id
  secure_boot_enabled             = var.secure_boot_enabled
  source_image_id                 = var.source_image_id
  user_data                       = var.user_data
  virtual_machine_scale_set_id    = var.virtual_machine_scale_set_id
  vtpm_enabled                    = var.vtpm_enabled
  zone                            = var.zone
  tags                            = var.tags

  os_disk {
    caching                          = var.os_disk.caching
    storage_account_type             = var.os_disk.storage_account_type
    disk_encryption_set_id           = var.os_disk.disk_encryption_set_id
    disk_size_gb                     = var.os_disk.disk_size_gb
    name                             = var.os_disk.name
    secure_vm_disk_encryption_set_id = var.os_disk.secure_vm_disk_encryption_set_id
    security_encryption_type         = var.os_disk.security_encryption_type
    write_accelerator_enabled        = var.os_disk.write_accelerator_enabled

    dynamic "diff_disk_settings" {
      for_each = var.os_disk.diff_disk_settings == null ? [] : [
        "diff_disk_settings"
      ]

      content {
        option    = var.os_disk.diff_disk_settings.option
        placement = var.os_disk.diff_disk_settings.placement
      }
    }
  }
  dynamic "additional_capabilities" {
    for_each = var.vm_additional_capabilities == null ? [] : [
      "additional_capabilities"
    ]

    content {
      ultra_ssd_enabled = var.vm_additional_capabilities.ultra_ssd_enabled
    }
  }
  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication ? [1] : []
    content {
      username   = try(var.admin_username, "azureuser")
      public_key = var.admin_ssh_key_data == null ? tls_private_key.rsa[0].public_key_openssh : var.admin_ssh_key_data
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = var.storage_account_name != null ? data.azurerm_storage_account.storeacc.0.primary_blob_endpoint : var.storage_account_uri
    }
  }

  dynamic "gallery_application" {
    for_each = toset(var.gallery_application)
    content {
      version_id             = var.gallery_application.version_id
      configuration_blob_uri = var.gallery_application.configuration_blob_uri
      order                  = var.gallery_application.order
      tag                    = var.gallery_application.tag
    }
  }

  dynamic "identity" {
    for_each = var.identity == null ? [] : ["identity"]

    content {
      type         = var.identity.type
      identity_ids = var.identity.identity_ids
    }
  }
  dynamic "plan" {
    for_each = var.plan == null ? [] : ["plan"]

    content {
      name      = var.plan.name
      product   = var.plan.product
      publisher = var.plan.publisher
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
  dynamic "source_image_reference" {
    for_each = var.source_image_reference == null ? [] : ["source_image_reference"]
    content {
      offer     = var.source_image_reference.offer
      publisher = var.source_image_reference.publisher
      sku       = var.source_image_reference.sku
      version   = var.source_image_reference.version
    }
  }
  dynamic "termination_notification" {
    for_each = var.termination_notification == null ? [] : ["termination_notification"]
    content {
      enabled = var.termination_notification.enabled
      timeout = var.termination_notification.timeout
    }
  }
}


#############################################
############  W I N D O W S V M  ############
#############################################

resource "azurerm_windows_virtual_machine" "vm_windows" {
  count = lower(local.os_type) == "windows" ? 1 : 0

  admin_password                = var.admin_password
  admin_username                = var.admin_username
  location                      = var.location
  name                          = var.name
  network_interface_ids         = var.network_interface_ids
  resource_group_name           = var.resource_group_name
  size                          = var.size
  allow_extension_operations    = var.allow_extension_operations
  availability_set_id           = var.availability_set_id
  capacity_reservation_group_id = var.capacity_reservation_group_id
  computer_name                 = var.computer_name
  custom_data                   = var.custom_data
  dedicated_host_group_id       = var.dedicated_host_group_id
  dedicated_host_id             = var.dedicated_host_id
  edge_zone                     = var.edge_zone
  enable_automatic_updates      = var.automatic_updates_enabled
  encryption_at_host_enabled    = var.encryption_at_host_enabled
  eviction_policy               = var.eviction_policy
  extensions_time_budget        = var.extensions_time_budget
  hotpatching_enabled           = var.hotpatching_enabled
  license_type                  = var.license_type
  max_bid_price                 = var.max_bid_price
  patch_assessment_mode         = var.patch_assessment_mode
  patch_mode                    = var.patch_mode
  platform_fault_domain         = var.platform_fault_domain
  priority                      = var.priority
  provision_vm_agent            = var.provision_vm_agent
  proximity_placement_group_id  = var.proximity_placement_group_id
  secure_boot_enabled           = var.secure_boot_enabled
  source_image_id               = var.source_image_id
  tags                          = var.tags
  timezone                      = var.timezone
  user_data                     = var.user_data
  virtual_machine_scale_set_id  = var.virtual_machine_scale_set_id
  vtpm_enabled                  = var.vtpm_enabled
  zone                          = var.zone

  os_disk {
    caching                          = var.os_disk.caching
    storage_account_type             = var.os_disk.storage_account_type
    disk_encryption_set_id           = var.os_disk.disk_encryption_set_id
    disk_size_gb                     = var.os_disk.disk_size_gb
    name                             = var.os_disk.name
    secure_vm_disk_encryption_set_id = var.os_disk.secure_vm_disk_encryption_set_id
    security_encryption_type         = var.os_disk.security_encryption_type
    write_accelerator_enabled        = var.os_disk.write_accelerator_enabled

    dynamic "diff_disk_settings" {
      for_each = var.os_disk.diff_disk_settings == null ? [] : [
        "diff_disk_settings"
      ]

      content {
        option    = var.os_disk.diff_disk_settings.option
        placement = var.os_disk.diff_disk_settings.placement
      }
    }
  }
  dynamic "additional_capabilities" {
    for_each = var.vm_additional_capabilities == null ? [] : [
      "additional_capabilities"
    ]

    content {
      ultra_ssd_enabled = var.vm_additional_capabilities.ultra_ssd_enabled
    }
  }
  dynamic "additional_unattend_content" {
    for_each = {
      for c in var.additional_unattend_contents : jsonencode(c) => c
    }

    content {
      content = additional_unattend_content.value.content
      setting = additional_unattend_content.value.setting
    }
  }
  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = var.storage_account_name != null ? data.azurerm_storage_account.storeacc.0.primary_blob_endpoint : var.storage_account_uri
    }
  }
  dynamic "gallery_application" {
    for_each = toset(var.gallery_application)
    content {
      version_id             = var.gallery_application.version_id
      configuration_blob_uri = var.gallery_application.configuration_blob_uri
      order                  = var.gallery_application.order
      tag                    = var.gallery_application.tag
    }
  }
  dynamic "identity" {
    for_each = var.identity == null ? [] : ["identity"]

    content {
      type         = var.identity.type
      identity_ids = var.identity.identity_ids
    }
  }
  dynamic "plan" {
    for_each = var.plan == null ? [] : ["plan"]

    content {
      name      = var.plan.name
      product   = var.plan.product
      publisher = var.plan.publisher
    }
  }
  dynamic "secret" {
    for_each = toset(var.secrets)

    content {
      key_vault_id = secret.value.key_vault_id

      dynamic "certificate" {
        for_each = secret.value.certificate
        content {
          store = certificate.value.store
          url   = certificate.value.url
        }
      }
    }
  }
  dynamic "source_image_reference" {
    for_each = var.source_image_reference == null ? [] : ["source_image_reference"]
    content {
      offer     = var.source_image_reference.offer
      publisher = var.source_image_reference.publisher
      sku       = var.source_image_reference.sku
      version   = var.source_image_reference.version
    }
  }
  dynamic "termination_notification" {
    for_each = var.termination_notification == null ? [] : ["termination_notification"]
    content {
      enabled = var.termination_notification.enabled
      timeout = var.termination_notification.timeout
    }
  }
  dynamic "winrm_listener" {
    for_each = var.winrm_listeners
    content {
      protocol        = winrm_listener.value.protocol
      certificate_url = winrm_listener.value.certificate_url
    }
  }
}

resource "azurerm_network_interface" "nic" {
  for_each                      = var.network_interface
  name                          = each.value.name
  resource_group_name           = each.value.resource_group_name
  location                      = each.value.location
  dns_servers                   = try(each.value.dns_servers, null)
  enable_ip_forwarding          = try(each.value.enable_ip_forwarding, false)
  enable_accelerated_networking = try(each.value.enable_accelerated_networking, false)
  internal_dns_name_label       = try(each.value.internal_dns_name_label, null)
  edge_zone                     = try(each.value.edge_zone, null)
  tags                          = merge({ "ResourceName" = each.value.name }, try(each.value.tags, null), )

  dynamic "ip_configuration" {
    for_each = lookup(each.value, "ip_configuration", null)
    content {
      name                          = ip_configuration.value["name"]
      primary                       = try(ip_configuration.value["primary"], false)
      subnet_id                     = try(ip_configuration.value.subnet_id, data.azurerm_subnet.snet[0].id)
      private_ip_address_allocation = try(ip_configuration.value["private_ip_address_allocation"], "Dynamic")
      private_ip_address            = ip_configuration.value["private_ip_address_allocation"] == "Static" ? ip_configuration.value["private_ip_address"] : null
    }
  }
}

resource "azurerm_managed_disk" "disk" {
  count = length(var.managed_disk)

  create_option                    = var.managed_disk[count.index]["create_option"]
  location                         = var.location
  name                             = var.managed_disk[count.index]["name"]
  resource_group_name              = var.resource_group_name
  storage_account_type             = try(var.managed_disk[count.index]["storage_account_type"], null)
  disk_access_id                   = try(var.managed_disk[count.index]["disk_access_id"], null)
  disk_encryption_set_id           = try(var.managed_disk[count.index]["disk_encryption_set_id"], null)
  disk_iops_read_only              = try(var.managed_disk[count.index]["disk_iops_read_only"], null)
  disk_iops_read_write             = try(var.managed_disk[count.index]["disk_iops_read_write"], null)
  disk_mbps_read_only              = try(var.managed_disk[count.index]["disk_mbps_read_only"], null)
  disk_mbps_read_write             = try(var.managed_disk[count.index]["disk_mbps_read_write"], null)
  disk_size_gb                     = try(var.managed_disk[count.index]["disk_size_gb"], null)
  edge_zone                        = try(var.edge_zone, null)
  gallery_image_reference_id       = try(var.managed_disk[count.index]["gallery_image_reference_id"], null)
  hyper_v_generation               = try(var.managed_disk[count.index]["hyper_v_generation"], null)
  image_reference_id               = try(var.managed_disk[count.index]["image_reference_id"], null)
  logical_sector_size              = try(var.managed_disk[count.index]["logical_sector_size"], null)
  max_shares                       = try(var.managed_disk[count.index]["max_shares"], null)
  network_access_policy            = try(var.managed_disk[count.index]["network_access_policy"], null)
  on_demand_bursting_enabled       = try(var.managed_disk[count.index]["on_demand_bursting_enabled"], null)
  os_type                          = contains(["import", "importsecure", "copy"], var.managed_disk[count.index]["create_option"]) ? local.os_type : null
  public_network_access_enabled    = try(var.managed_disk[count.index]["public_network_access_enabled"], null)
  secure_vm_disk_encryption_set_id = try(var.managed_disk[count.index]["secure_vm_disk_encryption_set_id"], null)
  security_type                    = try(var.managed_disk[count.index]["security_type"], null)
  source_resource_id               = try(var.managed_disk[count.index]["source_resource_id"], null)
  source_uri                       = try(var.managed_disk[count.index]["source_uri"], null)
  storage_account_id               = try(var.managed_disk[count.index]["storage_account_id"], null)
  tags                             = var.tags
  tier                             = try(var.managed_disk[count.index]["tier"], null)
  trusted_launch_enabled           = try(var.managed_disk[count.index]["trusted_launch_enabled"], null)
  upload_size_bytes                = try(var.managed_disk[count.index]["upload_size_bytes"], null)
  zone                             = try(var.zone, null)

  dynamic "encryption_settings" {
    for_each = lookup(var.managed_disk[count.index], "encryption_settings", []) #[] : ["encryption_settings"]

    content {
      dynamic "disk_encryption_key" {
        for_each = var.managed_disk[count.index]["encryption_settings"]["disk_encryption_key"] == null ? [] : [
          "disk_encryption_key"
        ]

        content {
          secret_url      = disk_encryption_key.value.secret_url
          source_vault_id = disk_encryption_key.value.source_vault_id
        }
      }
      dynamic "key_encryption_key" {
        for_each = var.managed_disk[count.index]["encryption_settings"]["key_encryption_key"] == null ? [] : [
          "key_encryption_key"
        ]

        content {
          key_url         = key_encryption_key.value.key_url
          source_vault_id = key_encryption_key.value.source_vault_id
        }
      }
    }
  }
}

locals {
  test = { for i, j in var.managed_disk : i => j }
}
resource "azurerm_virtual_machine_data_disk_attachment" "attachment" {
  for_each = { for i, j in var.managed_disk : i => j }

  caching                   = try(each.value.caching, "ReadWrite")
  lun                       = each.key
  managed_disk_id           = azurerm_managed_disk.disk[each.key].id
  virtual_machine_id        = local.virtual_machine.id
  create_option             = try(each.value.create_option_disk_attachment, "Attach")
  write_accelerator_enabled = try(each.value.write_accelerator_enabled, false)
}
