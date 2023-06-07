output "loadbalancer" {
  value = azurerm_lb.azlb
}

output "lb_public_IP" {
  value = azurerm_public_ip.azlb_public_ip
}