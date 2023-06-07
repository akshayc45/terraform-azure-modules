Azure Virtual Machines Terraform Module
----------------------------------------------------------------------------------------------------------
Terraform module to deploy azure Windows or Linux virtual machines with Public IP, proximity placement group, Availability Set, boot diagnostics, data disks, and Network Security Group support. It supports existing ssh keys or generates ssh key pairs if required for Linux VM's. It creates random passwords as well if you are not providing the custom password for Windows VM's.



Resources
---------------------------
Linux Virtual Machine
Windows Virtual Machine
Managed Data Disks
Boot Diagnostics
Availability Set
Public IP
Network Security Group
Managed Identities
Custom Data
SSH2 Key generation



Module Usages
-----------------------------
module "NIC" {
  source = ""
  network_interface = {
   "IP1" = {
      name = "az-lz-test-nic"
      location = "centralindia"
      resource_group_name = "az-lz-test"
      ip_configuration = [
        {
        name = "config-1"
        primary = true
        private_ip_address_allocation = "Dynamic"
        subnet_id = "/subscriptions/6060d873-eee6-4ce2-b031-7b6a99a9c9b5/resourceGroups/az-lz-test/providers/Microsoft.Network/virtualNetworks/az-lz-test-vnet/subnets/az-lz-snet-az1"
        },
        {
        name = "config-2"
        private_ip_address_allocation = "Dynamic"
        subnet_id = "/subscriptions/6060d873-eee6-4ce2-b031-7b6a99a9c9b5/resourceGroups/az-lz-test/providers/Microsoft.Network/virtualNetworks/az-lz-test-vnet/subnets/az-lz-snet-az1"
        }
      ]

    }
    "IP2" = {
      name = "az-lz-test2-nic"
      location = "centralindia"
      resource_group_name = "az-lz-test"
      ip_configuration = [
        {
        name = "config-1"
        primary = true
        private_ip_address_allocation = "Dynamic"
        subnet_id = "/subscriptions/6060d873-eee6-4ce2-b031-7b6a99a9c9b5/resourceGroups/az-lz-test/providers/Microsoft.Network/virtualNetworks/az-lz-test-vnet/subnets/az-lz-snet-az1"
        },
        {
        name = "config-2"
        private_ip_address_allocation = "Dynamic"
        subnet_id = "/subscriptions/6060d873-eee6-4ce2-b031-7b6a99a9c9b5/resourceGroups/az-lz-test/providers/Microsoft.Network/virtualNetworks/az-lz-test-vnet/subnets/az-lz-snet-az1"
        }
      ]
    }
  }
}

module "linux_vm" {
  source = ""
  os_type = "Linux"
location = "centralindia"
resource_group_name = "az-lz-test"
name = "az-lz-test"
size =  "Standard_D2S_V3"
admin_password = "Terraform@123"
network_interface_ids = [module.NIC.nic["IP1"].id, module.NIC.nic["IP2"].id]
os_disk = {
    caching = "ReadWrite"
    storage_account_type  = "StandardSSD_LRS"
      }
source_image_reference = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
managed_disk = [
  {
  name                 = "disk1"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
  caching = "ReadWrite"
  },
  {
  name                 = "disk2"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
  caching = "ReadWrite"
  }
]
}