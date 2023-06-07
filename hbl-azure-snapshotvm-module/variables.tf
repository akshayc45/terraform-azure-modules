variable "primary_network_interface_id" {
  default = null
}
variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created."
  type        = string
}

variable "location" {
  description = "(Optional) The location in which the resources will be created."
  type        = string
  default     = ""
}

# variable "vnet_subnet_id" {
#   description = "The subnet id of the virtual network where the virtual machines will reside."
#   type        = string
# }

variable "public_ip_dns" {
  description = "Optional globally unique per datacenter region domain name label to apply to each public ip address. e.g. thisvar.varlocation.cloudapp.azure.com where you specify only thisvar here. This is an array of names which will pair up sequentially to the number of public ips defined in var.nb_public_ip. One name or empty string is required for every public ip. If no public ip is desired, then set this to an array with a single empty string."
  type        = list(string)
  default     = [null]
}

variable "admin_password" {
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure."
  type        = string
  default     = ""
}

variable "extra_ssh_keys" {
  description = "Same as ssh_key, but allows for setting multiple public keys. Set your first key in ssh_key, and the extras here."
  type        = list(string)
  default     = []
}

variable "ssh_key" {
  description = "Path to the public key to be used for ssh access to the VM. Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash. e.g. c:/home/id_rsa.pub."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_key_values" {
  description = "List of Public SSH Keys values to be used for ssh access to the VMs."
  type        = list(string)
  default     = []
}
variable "remote_port" {
  description = "Remote tcp port to be used for access to the vms created via the nsg applied to the nics."
  type        = string
  default     = ""
}

variable "admin_username" {
  description = "The admin username of the VM that will be deployed."
  type        = string
  default     = ""
}

variable "custom_data" {
  description = "The custom data to supply to the machine. This can be used as a cloud-init for Linux systems."
  type        = string
  default     = ""
}

variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  type        = string
  default     = "Premium_LRS"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "nb_instances" {
  description = "Specify the number of vm instances."
  type        = number
  default     = 1
}

variable "vm_hostname" {
  description = "local name of the Virtual Machine."
  type        = string
  default     = "myvm"
}

variable "vm_os_simple" {
  description = "Specify UbuntuServer, WindowsServer, RHEL, openSUSE-Leap, CentOS, Debian, CoreOS and SLES to get the latest image version of the specified os.  Do not provide this value if a custom value is used for vm_os_publisher, vm_os_offer, and vm_os_sku."
  type        = string
  default     = ""
}

variable "vm_os_id" {
  description = "The resource ID of the image that you want to deploy if you are using a custom image.Note, need to provide is_windows_image = true for windows custom images."
  type        = string
  default     = ""
}

variable "is_windows_image" {
  description = "Boolean flag to notify when the custom image is windows based."
  type        = bool
  default     = false
}

variable "vm_os_publisher" {
  description = "The name of the publisher of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = ""
}

variable "vm_os_offer" {
  description = "The name of the offer of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = ""
}

variable "vm_os_sku" {
  description = "The sku of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = ""
}

variable "vm_os_version" {
  description = "The version of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = "latest"
}

variable "vm_name" {
  type = list(string)
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}

variable "allocation_method" {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  type        = string
  default     = "Dynamic"
}

variable "public_ip_sku" {
  description = "Defines the SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic."
  type        = string
  default     = "Basic"
}

variable "nb_public_ip" {
  description = "Number of public IPs to assign corresponding to one IP per vm. Set to 0 to not assign any public IP addresses."
  type        = number
  default     = 1
}

variable "delete_os_disk_on_termination" {
  type        = bool
  description = "Delete datadisk when machine is terminated."
  default     = false
}

variable "delete_data_disks_on_termination" {
  type        = bool
  description = "Delete data disks when machine is terminated."
  default     = false
}

variable "data_sa_type" {
  description = "Data Disk Storage Account type."
  type        = string
  default     = "Standard_LRS"
}

variable "data_disk_size_gb" {
  description = "Storage data disk size size."
  type        = number
  default     = 30
}

variable "vm_availability_zone" {
  type    = list(string)
  default = []
}

variable "boot_diagnostics" {
  type        = bool
  description = "(Optional) Enable or Disable boot diagnostics."
  default     = false
}

variable "boot_diagnostics_sa_type" {
  description = "(Optional) Storage account type for boot diagnostics."
  type        = string
  default     = "Standard_LRS"
}

variable "enable_accelerated_networking" {
  type        = bool
  description = "(Optional) Enable accelerated networking on Network interface."
  default     = false
}

variable "enable_ssh_key" {
  type        = bool
  description = "(Optional) Enable ssh key authentication in Linux virtual Machine."
  default     = true
}

# variable "nb_data_disk" {
#   description = "(Optional) Number of the data disks attached to each virtual machine."
#   type        = number
#   default     = 0
# }

variable "source_address_prefixes" {
  description = "(Optional) List of source address prefixes allowed to access var.remote_port."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "license_type" {
  description = "Specifies the BYOL Type for this Virtual Machine. This is only applicable to Windows Virtual Machines. Possible values are Windows_Client and Windows_Server"
  type        = string
  default     = null
}

variable "identity_type" {
  description = "The Managed Service Identity Type of this Virtual Machine."
  type        = string
  default     = ""
}

variable "enable_boot_diagnostics" {
  description = "Should the boot diagnostics enabled?"
  default     = false
}

variable "os_profile_windows_config" {
  type    = any
  default = {}
}
variable "identity_ids" {
  description = "Specifies a list of user managed identity ids to be assigned to the VM."
  type        = list(string)
  default     = []
}

variable "extra_disks" {
  description = "(Optional) List of extra data disks attached to each virtual machine."
  type        = any
  #type = list(object({
  # name = string
  # create_option = string
  # lun = number
  # disk_size_gb = number
  # managed_disk_type = string
  # caching = string
  # write_accelerator_enabled = bool
  # managed_disk_id = string
  # vhd_uri = string 
  #}))

  default = {}
}

variable "os_profile_secrets" {
  description = "Specifies a list of certificates to be installed on the VM, each list item is a map with the keys source_vault_id, certificate_url and certificate_store."
  #type        = list(map(string))
  type    = any
  default = {}
}

# variable "source_vault_id" {
#   default = null
# }
# variable "certificate_url" {
#   default = null
# }

variable "create_option" {
  description = "Specifies how the OS Disk should be created. Possible values are Attach (managed disks only) and FromImage"
  default     = "FromImage"
}

variable "caching" {
  default = "ReadWrite"
}

# variable "os_disk_size_gb" {
#   default = 128
# }

# variable "os_disk_image_uri" {
#   default = null
# }
variable "os_type" {
  default = null
}
variable "write_accelerator_enabled" {
  default = false
}

# variable "managed_disk_id" {
#   default = null
# }

variable "managed_disk_type" {
  default = "Standard_LRS"
}

variable "computer_name" {
  type    = string
  default = null
}
variable "provision_vm_agent" {
  default = false
}

variable "enable_automatic_upgrades" {
  default = false
}
variable "timezone" {
  default = null
}
variable "availability_set_id" {
  default = null
}

variable "ssh_keys" {
  default = null
}

# variable "managed_identity_type" {
#   default = null
# }
variable "nic_id" {
  default = []
}

# variable "managed_identity_ids" {
#   type = any
# }
# variable "winrm_protocol" {
#   type = any
#   default = null
# }

# variable "key_vault_certificate_secret_url" {
#   type = any
#   default = null
# }
variable "storage_account_uri" {
  type    = any
  default = null
}

variable "enable_ultra_ssd_data_disk_storage_support" {
  default = false
}

variable "additional_unattend_config" {
  type    = any
  default = null
}

variable "nsg_name" {
  description = "list of value of subnet name"
  type        = list(string)
  default     = []
}

variable "nsg_resource_group_name" {
  type = any
}
variable "storage_account_name" {
  type        = string
  description = "name of storage account for boot diagnostic logs"
  default     = null
}

variable "storage_account_resource_group_name" {
  type        = any
  description = "name of storage account resource group"
  default     = null
}

variable "subnet_name" {
  type        = string
  description = "name of subnet vm need to deploy"
  default     = null
}

variable "vnet_name" {
  type        = string
  description = "name of vnet"
  default     = null
}

variable "snet_resource_group_name" {
  type        = string
  description = "Resource Group name"
  default     = null
}



########################EXTRA
variable "win_nic_name" {
  type    = any
  default = []
}

variable "dns_servers" {
  type    = any
  default = []
}

variable "enable_ip_forwarding" {
  type    = any
  default = false
}

variable "internal_dns_name_label" {
  type    = any
  default = null
}

variable "ip_config_name" {
  type    = any
  default = []
}

variable "primary" {
  default = true
}
variable "private_ip_address_allocation_type" {
  description = "The allocation method used for the Private IP Address. Possible values are Dynamic and Static."
  default     = "Dynamic"
}
variable "private_ip_address" {
  description = "The Static IP Address which should be used. This is valid only when `private_ip_address_allocation` is set to `Static` "
  default     = null
}
variable "source_image_reference" {
  description = "Pre-defined Azure Windows VM images list"
  type        = any

  default = {
    "windowsserver" = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2016-Datacenter"
      version   = "latest"
    }
  }
}
variable "publisher" {
  default = null
}
variable "offer" {
  default = null
}

variable "sku" {
  default = null
}

variable "image_version" {
  type    = string
  default = "null"
}
variable "custom_image_publisher" {
  type    = any
  default = null
}
# variable "custom_image_publisher" {
#   default = null
# }

variable "custom_image_offer" {
  default = null
}
variable "custom_image_sku" {
  default = null
}

variable "custom_image_version" {
  default = null
}

# variable "os_disk_name" {
#   default = null
# }

############################DISK############
# variable "managed_disk_name" {
#   default = null
# }
# variable "os__managed_disk_name" {
#   default = null
# }

# variable "managed_disk_storage_account_type" {
#   default = null
# }
# variable "os_disk_storage_account_type" {
#   default = "Standard_LRS"
# }

# # variable "managed_disk_create_option" {
# #   default = null
# # }

# variable "os_disk_create_option" {
#   default = "Empty"
# }
# variable "managed_disk_zone" {
#   default = []
# }
# variable "os_managed_disk_zone" {
#   default = [null]
# }

# variable "disk_managed_size_gb" {
#   default = null
# }

# variable "os_managed_disk_size_gb" {
#   default = null
# }
# variable "source_resource_id" {
#   default = null
# }
# variable "os_source_resource_id" {
#   default = null
# }

variable "source_uri" {
  default = null
}
variable "os_source_uri" {
  default = null
}
variable "secure_vm_disk_encryption_set_id" {
  default = null
}
variable "os_secure_vm_disk_encryption_set_id" {
  default = null
}

variable "data_disk_name" {
  default = null
}
variable "disk_size_gb" {
  default = 128
}

variable "data_disk_lun" {
  default = 0
}

variable "data_disk_create_option" {
  default = "Empty"
}

variable "data_disk_disk_size_gb" {
  default = 128
}

variable "data_disk_managed_disk_type" {
  default = "Standard_LRS"
}

variable "data_disk_count" {
  default = 0
}
variable "disk_encryption_set_id" {
  default = null
}
variable "resource_group_name_disk_encryption" {
  type        = string
  description = "name of disk encryption set reosurce group"
  default     = null
}
variable "name_disk_encryption" {
  type        = string
  description = "name of disk encryption set"
  default     = null
}

variable "storage_os_disk" {
  type    = object()
  default = {}
}

variable "data_disk" {
  type    = any
  default = []
}

variable "storage_data_disk" {
  type    = any
  default = []
}


# variable "write_accelerator_enabled"{
#  default = null
# }

# variable "vhd_uri"{
#  default = null
# }
#  variable "storage_data_disk_name"{}
#  variable "storage_data_disk_creation_option"{
#    default = "Empty"
#  }
#  variable "storage_data_disk_lun"{
#    default = null
#  }

#  variable "storage_data_disk_size"{
#    default = 30
#  }

#  variable "managed_source_resource_id"{
#    default = null
#  }

#  variable "storage_data_disk_type" {
#    default  = null
#  }

#  variable "storage_data_disk_caching"{
#    default = null
#  }

#  variable "storage_data_disk_enable_accelerator" {
#    default = null
#  }

#  variable "storage_managed_disk_id" {
#    default = null
#  }
#variable "vhd_uri"{
#  default = null
#}
variable "data_disk_caching" {
  default = "ReadWrite"
}
variable "data_disk_tags" {
  type    = any
  default = []
}
# variable "os_disk_tags"{
#  type = any
#  default = []
# }
variable "nic_tags" {
  type    = any
  default = []
}
variable "vm_tags" {
  type    = any
  default = []
}
variable "os_profile_linux_config" {
  type    = any
  default = []
}
variable "key_path" {
  default = null
}

variable "key_data" {
  default = null
}
