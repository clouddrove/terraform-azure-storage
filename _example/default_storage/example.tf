provider "azurerm" {
  features {}
}

locals {
  name        = "app"
  environment = "test"
  label_order = ["name", "environment"]
}

##----------------------------------------------------------------------------- 
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "clouddrove/resource-group/azure"
  version     = "1.0.2"
  label_order = local.label_order
  name        = local.name
  environment = local.environment
  location    = "North Europe"
}

##----------------------------------------------------------------------------- 
## Virtual Network module call.
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "clouddrove/vnet/azure"
  version             = "1.0.3"
  name                = local.name
  environment         = local.environment
  label_order         = local.label_order
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
}

##----------------------------------------------------------------------------- 
## Subnet module call.
## Subnet in which storage account and its private endpoint will be created.
##-----------------------------------------------------------------------------
module "subnet" {
  source               = "clouddrove/subnet/azure"
  version              = "1.0.2"
  name                 = local.name
  environment          = local.environment
  label_order          = local.label_order
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = join("", module.vnet.vnet_name)
  service_endpoints    = ["Microsoft.Storage"]
  #subnet
  subnet_names    = ["subnet1"]
  subnet_prefixes = ["10.0.1.0/24"]

}

##----------------------------------------------------------------------------- 
## Log Analytics module call.
## Log analytics workspace in which storage diagnostic logs will be sent. 
##-----------------------------------------------------------------------------
module "log-analytics" {
  source                           = "clouddrove/log-analytics/azure"
  version                          = "1.0.1"
  name                             = local.name
  environment                      = local.environment
  label_order                      = local.label_order
  create_log_analytics_workspace   = true
  log_analytics_workspace_sku      = "PerGB2018"
  daily_quota_gb                   = "-1"
  internet_ingestion_enabled       = true
  internet_query_enabled           = true
  resource_group_name              = module.resource_group.resource_group_name
  log_analytics_workspace_location = module.resource_group.resource_group_location
}


##----------------------------------------------------------------------------- 
## Storage module call.
## Here default storage will be deployed i.e. storage account without cmk encryption. 
##-----------------------------------------------------------------------------
module "storage" {
  source                        = "../.."
  name                          = local.name
  environment                   = local.environment
  default_enabled               = true
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.resource_group_location
  storage_account_name          = "stordtyrey36"
  public_network_access_enabled = false
  ##   Storage Container
  containers_list = [
    { name = "app-test", access_type = "private" },
    { name = "app2", access_type = "private" },
  ]
  ##   Storage File Share
  file_shares = [
    { name = "fileshare1", quota = 5 },
  ]
  ##   Storage Tables
  tables = ["table1"]
  ## Storage Queues
  queues = ["queue1"]

  management_policy_enable = true
  #enable private endpoint
  virtual_network_id         = module.vnet.vnet_id[0]
  subnet_id                  = module.subnet.default_subnet_id[0]
  log_analytics_workspace_id = module.log-analytics.workspace_id
}
