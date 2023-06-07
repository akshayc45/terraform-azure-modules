azure nsg flow logs terraform Module
----------------------------------------------
Terraform module to deploy azure network security group, Netwrok Watcher, flow logs enable


Resources
-------------------------
azure network security group
azure network watcher
azure flowlogs


Module Usages
------------------------------

If new storage account tobe attache

module "nsg-flowlogs" {
  source = "../terraform-azure-lz/hbl-azure-nsg_flowlogs_networkwatcher-module"
  location = "centralindia"
nw_watch_name = "test-nw"
nw_rg = "az-lz-test"
nw_tags = {
  "created by" = "terraform"
}
flowlogs_resource_group_name = "az-lz-test"
storage_id = module.storage_account.storage_account["strorageaccount1"].id
  retention_policy = [
  {
    enabled = true
    days    = 7
  }
  ]
nsgrule = {
  "test-nsg" = {
    location = "centralindia"
    resource_group_name = "az-lz-test"
    tags = {
      "created by" = "terraform"
            }
    security_rule = [
      {
        name                       = "test123"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "test1234"
        priority                   = 101
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }
}
}

module "storage_account" {
  source = "../terraform-azure-lz/hbl-azure-storageaccount-module"
  storage_account = {
    "strorageaccount1" = {
  location = "centralindia"
  resource_group_name = "az-lz-test"
    }
}
}

-----------------------------------------------------------
If exesting storage account attache

module "nsg-flowlogs" {
  source = "../terraform-azure-lz/hbl-azure-nsg_flowlogs_networkwatcher-module"
  location = "centralindia"
nw_watch_name = "test-nw"
nw_rg = "az-lz-test"
nw_tags = {
  "created by" = "terraform"
}
flowlogs_resource_group_name = "az-lz-test"
storage_id = module.storage_account.storage_account["strorageaccount1"].id
  retention_policy = [
  {
    enabled = true
    days    = 7
  }
  ]
nsgrule = {
  "test-nsg" = {
    location = "centralindia"
    resource_group_name = "az-lz-test"
    storage_account_name = "storage_account_name"
    storage_account_resource_group_name = "storage_account_resource_group"
    tags = {
      "created by" = "terraform"
            }
    security_rule = [
      {
        name                       = "test123"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "test1234"
        priority                   = 101
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }
}
}


----------------------
if storage is differen subscription then update storage_id = "with_storage_account_id"