
###########################
#### LOG ANLY AUTO ACC ####
###########################

resource "azurerm_automation_account" "hbl-automationacc" {
  name                          = var.azurerm_automation_account_name
  location                      = var.location1
  resource_group_name           = var.azurerm_resource_group
  sku_name                      = var.sku_name
  public_network_access_enabled = var.public_network_access_enabled

  tags = merge({ "ResourceName" = "var.azurerm_automation_account_name" }, var.tags_automation_acc)
}

resource "azurerm_log_analytics_workspace" "hbl-loganalyticsws" {
  name                       = var.azurerm_log_analytics_workspace_name
  location                   = var.location1
  resource_group_name        = var.azurerm_resource_group
  sku                        = var.sku
  retention_in_days          = var.retention_in_days
  daily_quota_gb             = var.daily_quota_gb
  internet_ingestion_enabled = var.internet_ingestion_enabled
  internet_query_enabled     = var.internet_query_enabled
  tags                       = merge({ "ResourceName" = "var.var.azurerm_log_analytics_workspace_name" }, var.tags_automation_acc)
}



resource "azurerm_log_analytics_linked_service" "hbl-linked-service" {
  resource_group_name = var.azurerm_resource_group
  workspace_id        = azurerm_log_analytics_workspace.hbl-loganalyticsws.id
  read_access_id      = azurerm_automation_account.hbl-automationacc.id
  depends_on          = [azurerm_log_analytics_workspace.hbl-loganalyticsws, azurerm_automation_account.hbl-automationacc]

}
