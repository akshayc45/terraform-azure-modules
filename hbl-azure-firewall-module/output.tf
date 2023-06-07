output "apg" {
  value = azurerm_application_gateway.main
}

output "lb" {
  value = azurerm_lb.azlb
}

output "backend_pool" {
  value = azurerm_lb_backend_address_pool.azlb_backend_pool
}

output "name" {
  value = azurerm_network_security_group.nsg
}