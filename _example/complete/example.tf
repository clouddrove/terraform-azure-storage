provider "azurerm" {
  storage_use_azuread = true
  features {}
}

data "azurerm_client_config" "current_client_config" {}

locals {
  name        = "storage"
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
  create_log_analytics_workspace   = false
  log_analytics_workspace_sku      = "PerGB2018"
  daily_quota_gb                   = "-1"
  internet_ingestion_enabled       = true
  internet_query_enabled           = true
  resource_group_name              = module.resource_group.resource_group_name
  log_analytics_workspace_location = module.resource_group.resource_group_location
}

##----------------------------------------------------------------------------- 
## Key Vault module call.
##-----------------------------------------------------------------------------
module "vault" {
  source  = "clouddrove/key-vault/azure"
  version = "1.1.0"

  name                        = "vault8767768"
  environment                 = "test"
  label_order                 = ["name", "environment", ]
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
  admin_objects_ids           = [data.azurerm_client_config.current_client_config.object_id]
  virtual_network_id          = join("", module.vnet.vnet_id)
  subnet_id                   = module.subnet.default_subnet_id[0]
  enable_rbac_authorization   = true
  enabled_for_disk_encryption = false
  network_acls                = null
  #private endpoint
  enable_private_endpoint = false
  ########Following to be uncommnented only when using DNS Zone from different subscription along with existing DNS zone.

  # diff_sub                                      = true
  # alias                                         = ""
  # alias_sub                                     = ""

  #########Following to be uncommmented when using DNS zone from different resource group or different subscription.
  # existing_private_dns_zone                     = ""
  # existing_private_dns_zone_resource_group_name = ""

  #### enable diagnostic setting
  diagnostic_setting_enable  = true
  log_analytics_workspace_id = module.log-analytics.workspace_id ## when diagnostic_setting_enable enable,  add log analytics workspace id
}

##----------------------------------------------------------------------------- 
## Storage module call.
## Here storage account will be deployed with CMK encryption. 
##-----------------------------------------------------------------------------
module "storage" {
  source                        = "../.."
  name                          = local.name
  environment                   = local.environment
  label_order                   = local.label_order
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.resource_group_location
  storage_account_name          = "storage877656"
  public_network_access_enabled = true
  account_kind                  = "StorageV2"
  account_tier                  = "Standard"
  identity_type                 = "UserAssigned"
  object_id                     = [data.azurerm_client_config.current_client_config.object_id]
  account_replication_type      = "ZRS"
  cmk_enabled                   = true

  ###customer_managed_key can only be set when the account_kind is set to StorageV2 or account_tier set to Premium, and the identity type is UserAssigned.
  key_vault_id = module.vault.id
  ##   Storage Container
  containers_list = [
    { name = "app-test", access_type = "private" },
  ]
  tables = ["table1"]
  queues = ["queue1"]
  file_shares = [
    { name = "fileshare", quota = "10" },
  ]

  virtual_network_id         = module.vnet.vnet_id[0]
  subnet_id                  = module.subnet.default_subnet_id[0]
  log_analytics_workspace_id = module.log-analytics.workspace_id
}