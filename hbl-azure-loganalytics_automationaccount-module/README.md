#filename : managementgroups.tf
#variables file : variables.tf
#purpose : this code created management group hierarchy upto level 3
#Author : Deval Sutaria , CXIO
# Module files should not be changed in any case. These files are reusable and values must be passed from outside module.

Log analytics workspace and automation account terraform Module
----------------------------------------------
log analytic workspace and automation account creation


Resources
-------------------------
Log analytics workspace
Automation Account


Module Usages
------------------------------

#######################
module "log_analytics" {
source = ""
location1= "Central india"
azurerm_resource_group = "hbl-azure-ci-mgmt-devuat-logging-monitoring-rg"
########Log analytics variables#################
azurerm_log_analytics_workspace_name = "hbl-azure-ci-mgmt-spoke-devuat-log-workspace"
retention_in_days = 30
daily_quota_gb = "-1"
internet_ingestion_enabled = "true"
internet_query_enabled = "true"
sku = "PerGB2018"
reservation_capacity_in_gb_per_day = 10
tags_log_analytics = {}
###################################################
########automation Group variables#################
azurerm_automation_account_name = "hbl-azure-ci-mgmt-spoke-devuat-automation-acc"
sku_name = "Basic"
public_network_access_enabled = "true"
tags_automation_acc = {}
}
