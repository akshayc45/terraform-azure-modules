resource "azurerm_storage_share" "bootstrap" {
  name                 = var.file_share_name
  storage_account_name = azurerm_storage_account.bootstrap.name
  quota                = var.quota
  depends_on = [ azurerm_storage_account.bootstrap ]
}
resource "azurerm_storage_share_file" "bootstrap" {
  count = length(var.source_file)
  name             = element(var.destination_file, count.index)
  storage_share_id = azurerm_storage_share.bootstrap.id
  source           = element(var.source_file, count.index)
  path = element(var.path_file, count.index)
  depends_on = [ azurerm_storage_account.bootstrap, azurerm_storage_share.bootstrap ]
}

resource "azurerm_storage_share_directory" "share_directory" {
  count = length(var.share_directories)
  name                 = element(var.share_directories, count.index)
  share_name           = azurerm_storage_share.bootstrap.name
  storage_account_name = azurerm_storage_account.bootstrap.name
}

resource "azurerm_storage_account" "bootstrap" {
  name                      = var.storage_account_name
  account_tier              = var.account_tier
  account_replication_type  = var.account_replication_type
  location                  = var.location
  resource_group_name       = var.resource_group_name_for_internetinbound
  #depends_on                = [azurerm_resource_group.vmss]
  enable_https_traffic_only = var.enable_https_traffic_only
}