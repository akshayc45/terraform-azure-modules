load balancer terraform Module
----------------------------------------------
Terraform Module for Load Balancer with multiple resources as lb probe, lb rule, nat rule, backend pool and association



Resources
-------------------------
azure Load Balancer
azurerm public ip
frontend ip configuration
azurerm lb backend address pool
azurerm lnat rule
azurerm lb probe
azurerm lb rule
azurerm lb nat pool
azurerm network interface backend address pool association

Module Usages
------------------------------
  module "loadblancer_1" {
    source = "../../terraform-azure-lz/hbl-azure-loadbalancer-module"
    loadbalancer_name = "test_lb"
    resource_group_name = "az-lz-test"
  lb_sku = "Basic"
  lb_subnet_name = "az-lz-snet-az1"
  lb_vnet_name = "az-lz-test-vnet"
  lb_snet_resource_group = "az-lz-test"
  feip_configuration = [
  {
      name = "fronend-ip-config-1"
  }
    ]

    azlb_rule = {
    "LBRule-1" =  {
    protocol                       = "Tcp"
    frontend_port                  = 22
    backend_port                   = 22
    frontend_ip_configuration_name = "fronend-ip-config-1"
      }
      "LBRule-2" =  {
    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "fronend-ip-config-1"
      },
    }

    nat_rule = {
        "Nat_rule-1" = {
      protocol                       = "Tcp"
      frontend_port_start            = 3306
      frontend_port_end              = 3306
      backend_port                   = 3306
      frontend_ip_configuration_name = "fronend-ip-config-1"
        }
      "Nat_rule-2" = {
    protocol                       = "Tcp"
    frontend_port_start            = 8081
    frontend_port_end              = 8081
    backend_port                   = 8081
    frontend_ip_configuration_name = "fronend-ip-config-1"
      }
    }


  backend_pool_association = {
    "association-1" = {
        network_interface_id = module.NIC.nic["IP1"].id
        ip_configuration_name = "config-1"
    }
      "association-2" = {
        network_interface_id = module.NIC.nic["IP1"].id
        ip_configuration_name = "config-2"
    }
  }
    network_interface_id = [module.NIC.nic["IP1"].id, module.NIC.nic["IP2"].id]
    ip_configuration_name = [ "config-1", "config-2"]
    depends_on = [ module.NIC ]
  }

---------------------------------
Call block accordingly and create load balancer. 
Nat Rule and Nat pool can not user at the same time.