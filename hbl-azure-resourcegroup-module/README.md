#filename : main.tf
#variables file : variables.tf
#purpose : this code creates resource group, route table, vnet, subnet, subnet delegation, subnet rout table assocciatona and epeering connection between two vnets in different subscriptions
#Author : Deval Sutaria , CXIO
# Module files should not be changed in any case. These files are reusable and values must be passed from outside module.

```
provider "azurerm" {
  features {}
}

module "rg" {
 source = ""
 rg_name = ["az-lz-test1","az-lz-test2"]
 rg_location = ["centralindia","southindia"]
  rg_tags = {
   "CreatedBy" = "TerraformTest"
  }
}


```