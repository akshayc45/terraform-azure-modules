output "nic" {
  value = azurerm_network_interface.nic
}

output "managed_disk_count" {
  value = local.test
}