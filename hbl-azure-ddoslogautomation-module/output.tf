output "ddos_id" {
  value = [for i in azurerm_network_ddos_protection_plan.hbl-ddos_prt : i.id]
}
