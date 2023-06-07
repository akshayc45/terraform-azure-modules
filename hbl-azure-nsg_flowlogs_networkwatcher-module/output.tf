output "network_watcher" {
  value = azurerm_network_watcher.hbl-nw_watcher
}

output "nsg" {
  value = azurerm_network_security_group.hbl-nsg
}

output "flow-logs" {
  value = azurerm_network_watcher_flow_log.hbl-flow_logs
}