locals {
  vm_data_disks = { for idx, data_disk in var.data_disk : data_disk.name => {
    idx : idx,
    data_disk : data_disk,
    }
  }
  vm_data_disks1 = [for i in range(length(var.data_disk)) : i]
}
resource "tls_private_key" "rsa" {
  count     = var.enable_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}
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
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.snet_resource_group_name
}

data "azurerm_disk_encryption_set" "encrypt_disk" {
  count               = var.name_disk_encryption != null ? 1 : 0
  name                = var.name_disk_encryption
  resource_group_name = var.resource_group_name_disk_encryption
}
#############################
#OS_DISK#####################
#############################
resource "azurerm_managed_disk" "os_disk" {
  count = var.create_option != "FromImage" ? length(var.managed_os_disk) : []
  #name                 = "${var.managed_disk_name}_${index(var.vm_name, element(var.vm_name, count.index))}"
  name                   = "${element(var.vm_name, count.index)}-os_disk"
  location               = var.location
  resource_group_name    = var.resource_group_name
  storage_account_type   = var.managed_os_disk[count.index].storage_account_type
  create_option          = var.managed_os_disk[count.index].create_option
  zone                   = try(var.managed_os_disk[count.index].zone, null)
  disk_size_gb           = var.managed_os_disk[count.index].disk_size_gb
  source_resource_id     = var.managed_os_disk[count.index].create_option == "Copy" ? var.managed_os_disk[count.index].source_resource_id : null
  source_uri             = var.managed_os_disk[count.index].create_option == "Import" || var.managed_os_disk[count.index].create_option == "Restore" ? var.managed_os_disk[count.index].source_uri : null
  image_reference_id     = var.managed_os_disk[count.index].create_option == "FromImage" ? var.managed_os_disk[count.index].source_uri : null
  disk_encryption_set_id = try(var.disk_encryption_set_id != null ? var.disk_encryption_set_id : data.azurerm_disk_encryption_set.encrypt_disk[0].id, null)
  tags                   = merge({ "ResourceName" = "${element(var.vm_name, count.index)}-os_disk" }, var.managed_os_disk[count.index].tags)
}
##############################
resource "azurerm_network_interface" "nic" {
  count                         = length(var.win_nic_name)
  name                          = element(var.win_nic_name, count.index)
  resource_group_name           = var.resource_group_name
  location                      = var.location
  dns_servers                   = var.dns_servers
  enable_ip_forwarding          = var.enable_ip_forwarding
  enable_accelerated_networking = var.enable_accelerated_networking
  internal_dns_name_label       = var.internal_dns_name_label
  tags                          = merge({ "ResourceName" = element(var.win_nic_name, count.index) }, var.nic_tags, )

  dynamic "ip_configuration" {
    for_each = lenght(var.ip_config)
    content {
      name                          = ip_configuration.value["name"]
      primary                       = ip_configuration.value["primary"]
      subnet_id                     = data.azurerm_subnet.snet.id
      private_ip_address_allocation = ip_configuration.value["private_ip_address_allocation"]
      private_ip_address            = var.ip_configuration.value["private_ip_address_allocation"] == "Static" ? ip_configuration.value["private_ip_address"] : null
    }
  }
}
##############################
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  count                     = var.nsg_name != null ? length(var.nsg_name) : 0
  network_interface_id      = length(var.nic_id) != 0 ? element(var.nic_id, count.index) : azurerm_network_interface.nic[count.index].id
  network_security_group_id = data.azurerm_network_security_group.nsg_ext[count.index].id
}

######################################################
############### L I N U X M A C H I N E ##############
###################################################### 

resource "azurerm_virtual_machine" "vm-linux" {
  count               = lower(var.os_type) == "linux" ? length(var.vm_name) : 0
  name                = element(var.vm_name, count.index)
  resource_group_name = var.resource_group_name
  location            = var.location
  availability_set_id = var.availability_set_id
  vm_size             = var.vm_size
  #  network_interface_ids        = length(var.nic_id) != 0 ? [element(var.nic_id, count.index)] : [element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)  
  network_interface_ids            = length(var.nic_id) != 0 ? var.nic_id : [element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)]
  zones                            = try(var.vm_availability_zone, null)
  delete_os_disk_on_termination    = var.delete_os_disk_on_termination
  delete_data_disks_on_termination = var.delete_data_disks_on_termination
  primary_network_interface_id     = var.primary_network_interface_id
  tags                             = merge({ "ResourceName" = element(var.vm_name, count.index) }, var.vm_tags, )

  dynamic "identity" {
    for_each = var.managed_identity_type != null ? [1] : []
    content {
      type         = var.managed_identity_type
      identity_ids = var.managed_identity_type == "UserAssigned" || var.managed_identity_type == "SystemAssigned, UserAssigned" ? var.managed_identity_ids : null
    }
  }

  dynamic "storage_image_reference" {
    for_each = var.create_option != "Attach" ? [1] : []
    content {
      id        = var.vm_os_id
      publisher = var.vm_os_id != null ? var.custom_image_publisher != null ? var.custom_image_publisher : var.publisher : null
      offer     = var.vm_os_id != null ? var.custom_image_offer != null ? var.custom_image_offer : var.offer : null
      sku       = var.vm_os_id != null ? var.custom_image_sku != null ? var.custom_image_sku : var.sku : null
      version   = var.vm_os_id != null ? var.custom_image_version != null ? var.custom_image_version : var.image_version : null
    }
  }

  dynamic "plan" {
    for_each = var.custom_image_publisher != null ? [1] : []
    content {
      name      = try(var.plan_name, null)
      publisher = try(var.plan_publisher, null)
      product   = try(var.plan_product, null)
    }
  }
  storage_os_disk {
    name                      = "${element(var.vm_name, count.index)}-os_disk"
    create_option             = var.storage_os_disk.create_option
    caching                   = var.storage_os_disk.caching
    disk_size_gb              = var.storage_os_disk.disk_size_gb
    image_uri                 = var.storage_os_disk.image_uri
    os_type                   = var.os_type
    write_accelerator_enabled = try(var.storage_os_disk.write_accelerator_enabled, false)
    managed_disk_id           = var.create_option == "Attach" ? azurerm_managed_disk.os_disk[0].id : null
    managed_disk_type         = var.storage_os_disk.managed_disk_type
  }

  dynamic "storage_data_disk" {
    for_each = length(var.storage_data_disk) > 0 ? var.storage_data_disk : []
    content {
      name                      = storage_data_disk.value["name"]
      create_option             = storage_data_disk.value["create_option"]
      lun                       = storage_data_disk.key
      disk_size_gb              = storage_data_disk.value["disk_size_gb"]
      managed_disk_type         = try(storage_data_disk.value.managed_disk_type, "Standard_LRS")
      caching                   = try(storage_data_disk.value.caching, "ReadWrite")
      write_accelerator_enabled = try(storage_data_disk.value.write_accelerator_enabled, false)
      managed_disk_id           = storage_data_disk.value.create_option == "Attach" ? azurerm_managed_disk.managed_disk[storage_data_disk.key].id : null
    }
  }


  dynamic "os_profile" {
    for_each = var.create_option != "Attach" ? [1] : []
    content {
      computer_name  = var.computer_name
      admin_username = var.admin_username
      admin_password = var.enable_ssh_key ? null : var.admin_password
    }
  }

  dynamic "os_profile_linux_config" {
    for_each = var.create_option != "Attach" && length(var.os_profile_linux_config) > 0 ? [var.os_profile_linux_config] : []
    content {
      disable_password_authentication = var.enable_ssh_key

      dynamic "ssh_keys" {
        for_each = var.enable_ssh_key ? [1] : []
        content {
          path     = var.key_path == null ? "/home/${var.admin_username}/.ssh/authorized_keys" : var.key_path
          key_data = var.key_data == null ? tls_private_key.rsa[0].public_key_openssh : var.key_data
        }
      }
    }

    dynamic "os_profile_secrets" {
      for_each = length(var.os_profile_secrets) < 0 ? {} : var.os_profile_secrets
      content {
        source_vault_id = os_profile_secrets.value["source_vault_id"]


        vault_certificates {
          certificate_url   = os_profile_secrets.value["certificate_url"]
          certificate_store = os_profile_secrets.value["certificate_store"]
        }
      }
    }
    additional_capabilities {
      ultra_ssd_enabled = var.enable_ultra_ssd_data_disk_storage_support
    }


    dynamic "boot_diagnostics" {
      for_each = var.enable_boot_diagnostics ? [1] : []
      content {
        enabled     = var.boot_diagnostics
        storage_uri = try(var.storage_account_name != null ? data.azurerm_storage_account.storeacc.0.primary_blob_endpoint : var.storage_account_uri, null)
      }
    }

  }
}
###############################################################################################
# W I N D O W S M A C H I N E                                                                 #
###############################################################################################

resource "azurerm_virtual_machine" "vm-windows" {
  count               = var.os_type == "Windows" ? length(var.vm_name) : 0
  name                = element(var.vm_name, count.index)
  resource_group_name = var.resource_group_name
  location            = var.location
  availability_set_id = var.availability_set_id
  vm_size             = var.vm_size
  #network_interface_ids        = length(var.nic_id) != 0 ? [element(var.nic_id, count.index)] : [element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)]
  network_interface_ids         = length(var.nic_id) != 0 ? var.nic_id : [element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)]
  delete_os_disk_on_termination = var.delete_os_disk_on_termination
  license_type                  = var.license_type
  zones                         = try(var.vm_availability_zone, null)
  tags                          = merge({ "ResourceName" = element(var.vm_name, count.index) }, var.vm_tags, )

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  dynamic "storage_image_reference" {
    for_each = var.create_option != "Attach" ? [1] : []
    content {
      id        = var.vm_os_id
      publisher = var.custom_image_publisher != null ? var.custom_image_publisher : var.publisher
      offer     = var.custom_image_offer != null ? var.custom_image_offer : var.offer
      sku       = var.custom_image_sku != null ? var.custom_image_sku : var.sku
      version   = var.custom_image_version != null ? var.custom_image_version : var.image_version
    }
  }
  dynamic "plan" {
    for_each = var.custom_image_publisher != null ? [1] : []
    content {
      name      = try(var.plan_name, null)
      publisher = try(var.plan_publisher, null)
      product   = try(var.plan_product, null)
    }
  }

  storage_os_disk {
    name                      = "${element(var.vm_name, count.index)}-os_disk"
    create_option             = var.storage_os_disk.create_option
    caching                   = var.storage_os_disk.caching
    disk_size_gb              = var.storage_os_disk.disk_size_gb
    image_uri                 = var.storage_os_disk.image_uri
    os_type                   = var.os_type
    write_accelerator_enabled = try(var.storage_os_disk.write_accelerator_enabled, false)
    managed_disk_id           = var.create_option == "Attach" ? azurerm_managed_disk.os_disk[0].id : null
    managed_disk_type         = var.storage_os_disk.managed_disk_type
  }
  dynamic "storage_data_disk" {
    for_each = length(var.storage_data_disk) > 0 ? var.storage_data_disk : []
    content {
      #count = var.data_disk_count !=0 ? var.data_disk_count : 0
      name          = storage_data_disk.value["name"]
      create_option = storage_data_disk.value["create_option"]
      #lun               = storage_data_disk.value["lun"]
      lun                       = storage_data_disk.key
      disk_size_gb              = storage_data_disk.value["disk_size_gb"]
      managed_disk_type         = try(storage_data_disk.value.managed_disk_type, "Standard_LRS")
      caching                   = try(storage_data_disk.value.caching, "ReadWrite")
      write_accelerator_enabled = try(storage_data_disk.value.write_accelerator_enabled, false)
      managed_disk_id           = storage_data_disk.value.create_option == "Attach" ? azurerm_managed_disk.managed_disk[storage_data_disk.key].id : null
    }
  }

  dynamic "os_profile" {
    for_each = var.create_option != "Attach" ? [1] : []
    content {
      computer_name  = var.computer_name
      admin_username = var.admin_username
      admin_password = var.admin_password
    }
  }

  #tags = var.tags

  dynamic "os_profile_windows_config" {
    for_each = var.create_option != "Attach" && length(var.os_profile_windows_config) > 0 ? [var.os_profile_windows_config] : []
    content {
      provision_vm_agent        = try(os_profile_windows_config.value.provision_vm_agent, false)
      enable_automatic_upgrades = try(os_profile_windows_config.value.enable_automatic_upgrades, false)
      timezone                  = try(os_profile_windows_config.value.timezone, null)

      dynamic "additional_unattend_config" {
        for_each = try([os_profile_windows_config.value.additional_unattend_config], [])
        content {
          pass         = try(additional_unattend_config.value.pass, null)
          component    = try(additional_unattend_config.value.component, null)
          setting_name = try(additional_unattend_config.value.setting_name, null)
          content      = try(additional_unattend_config.value.content, null)
        }
      }
    }
  }

  dynamic "os_profile_secrets" {
    for_each = length(var.os_profile_secrets) < 0 ? {} : var.os_profile_secrets
    content {
      source_vault_id = os_profile_secrets.value["source_vault_id"]


      vault_certificates {
        certificate_url   = os_profile_secrets.value["certificate_url"]
        certificate_store = os_profile_secrets.value["certificate_store"]
      }
    }
  }
  additional_capabilities {
    ultra_ssd_enabled = var.enable_ultra_ssd_data_disk_storage_support
  }
  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      enabled     = var.boot_diagnostics
      storage_uri = try(var.storage_account_name != null ? data.azurerm_storage_account.storeacc.0.primary_blob_endpoint : var.storage_account_uri, null)
    }
  }
  # dynamic "winrm" {
  #   for_each = var.winrm_protocol != null ? [1] : []
  #   content {
  #     protocol        = var.winrm_protocol
  #     certificate_url = var.winrm_protocol == "Https" ? var.key_vault_certificate_secret_url : null
  #   }
  # }
}

################################
# MANAGED DISK##################
################################
resource "azurerm_managed_disk" "managed_disk" {
  count = length(var.data_disk)
  #name                 = "${var.managed_disk_name}_${index(var.vm_name, element(var.vm_name, count.index))}"
  name                   = var.data_disk[count.index]["name"]
  location               = var.data_disk[count.index]["location"]
  resource_group_name    = var.data_disk[count.index]["resource_group_name"]
  storage_account_type   = var.data_disk[count.index]["storage_account_type"]
  create_option          = var.data_disk[count.index]["create_option"]
  zone                   = try(var.data_disk[count.index]["zone"], null)
  disk_size_gb           = var.data_disk[count.index]["disk_size_gb"]
  source_resource_id     = var.data_disk[count.index]["create_option"] == "Copy" ? var.data_disk[count.index]["source_resource_id"] : null
  source_uri             = var.data_disk[count.index]["create_option"] == "Import" || var.data_disk[count.index]["create_option"] == "Restore" ? var.data_disk[count.index]["source_uri"] : null
  image_reference_id     = var.data_disk[count.index]["create_option"] == "FromImage" ? var.data_disk[count.index]["source_uri"] : null
  disk_encryption_set_id = try(var.disk_encryption_set_id != null ? var.disk_encryption_set_id : data.azurerm_disk_encryption_set.encrypt_disk[0].id, null)
  tags                   = merge({ "ResourceName" = var.data_disk[count.index]["name"] }, var.data_disk_tags)
  lifecycle {
    ignore_changes = [tags, disk_encryption_set_id, disk_iops_read_only, disk_iops_read_write, disk_mbps_read_only, disk_mbps_read_write, hyper_v_generation, id, logical_sector_size, max_shares, on_demand_bursting_enabled, source_uri, tier, trusted_launch_enabled, os_type
    ]
  }
}
resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  for_each        = local.vm_data_disks
  managed_disk_id = azurerm_managed_disk.managed_disk[each.value.idx].id
  #  managed_disk_id    = azurerm_managed_disk.managed_disk[each.value.idx + 1].id
  #  virtual_machine_id = var.os_flavor == "linux" ? azurerm_linux_virtual_machine.linx_vm[each.value.idx].id : "123"
  virtual_machine_id = var.os_type == "Linux" ? join("", [for i in azurerm_virtual_machine.vm-linux : i.id]) : join("", [for i in azurerm_virtual_machine.vm-windows : i.id])
  lun                = each.value.idx
  caching            = "ReadWrite"
}