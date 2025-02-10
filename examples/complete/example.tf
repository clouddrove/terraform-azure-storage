
provider "azurerm" {
  features {}
  storage_use_azuread = true
  subscription_id     = "000001-11111-1223-XXX-XXXXXXXXXXXX"
}

provider "azurerm" {
  features {}
  alias           = "peer"
  subscription_id = "000001-11111-1223-XXX-XXXXXXXXXXXX"
}


data "azurerm_client_config" "current_client_config" {}

locals {
  name        = "app-storage"
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
  version             = "1.0.4"
  name                = local.name
  environment         = local.environment
  label_order         = local.label_order
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

##----------------------------------------------------------------------------- 
## Subnet module call.
## Subnet in which storage account and its private endpoint will be created.
##-----------------------------------------------------------------------------
module "subnet" {
  source               = "clouddrove/subnet/azure"
  version              = "1.2.0"
  name                 = local.name
  environment          = local.environment
  label_order          = local.label_order
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
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
  version                          = "2.0.0"
  name                             = local.name
  environment                      = local.environment
  label_order                      = local.label_order
  create_log_analytics_workspace   = true # Set  it 'false' if you don't want resource log-analytics workspace to be created
  log_analytics_workspace_sku      = "PerGB2018"
  daily_quota_gb                   = "-1"
  internet_ingestion_enabled       = true
  internet_query_enabled           = true
  resource_group_name              = module.resource_group.resource_group_name
  log_analytics_workspace_location = module.resource_group.resource_group_location
  storage_account_id               = module.storage.storage_account_id
  diagnostic_setting_enable        = false # Set it 'true' if you want azurerm_monitor_diagnostic_setting to be enabled

}

##----------------------------------------------------------------------------- 
## Key Vault module call.
##-----------------------------------------------------------------------------
module "vault" {
  providers = {
    azurerm.main_sub = azurerm
    azurerm.dns_sub  = azurerm.peer
  }

  source  = "clouddrove/key-vault/azure"
  version = "1.1.0"

  name                        = "vae59605811"
  environment                 = "test"
  label_order                 = ["name", "environment", ]
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
  admin_objects_ids           = [data.azurerm_client_config.current_client_config.object_id]
  virtual_network_id          = module.vnet.vnet_id
  subnet_id                   = module.subnet.default_subnet_id[0]
  enable_rbac_authorization   = true
  enabled_for_disk_encryption = false
  #private endpoint
  enable_private_endpoint = false
  network_acls            = null
  
  ########Following to be uncommnented only when using DNS Zone from different subscription along with existing DNS zone.

  # diff_sub                                      = true
  # alias                                         = ""
  # alias_sub                                     = ""

  #########Following to be uncommmented when using DNS zone from different resource group or different subscription.
  # existing_private_dns_zone                     = ""
  # existing_private_dns_zone_resource_group_name = ""

  #### enable diagnostic setting
  diagnostic_setting_enable  = false
  log_analytics_workspace_id = module.log-analytics.workspace_id ## when diagnostic_setting_enable enable,  add log analytics workspace id
}

##----------------------------------------------------------------------------- 
## Storage module call.
## Here storage account will be deployed with CMK encryption. 
##-----------------------------------------------------------------------------
module "storage" {
  providers = {
    azurerm.dns_sub  = azurerm.peer,
    azurerm.main_sub = azurerm
  }

  source                        = "../.."
  name                          = local.name
  environment                   = local.environment
  label_order                   = local.label_order
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.resource_group_location
  storage_account_name          = "storage87482"
  public_network_access_enabled = true
  account_kind                  = "StorageV2"
  account_tier                  = "Standard"
  admin_objects_ids             = [data.azurerm_client_config.current_client_config.object_id]
  network_rules = [
  {
    default_action             = "Allow"
    ip_rules                   = ["0.0.0.0/0"]
    virtual_network_subnet_ids = []
    bypass                     = ["AzureServices"]
  }]

  ###customer_managed_key can only be set when the account_kind is set to StorageV2 or account_tier set to Premium, and the identity type is UserAssigned.
  cmk_encryption_enabled = true
  key_vault_id           = module.vault.id

  ########Following to be uncommnented only when using DNS Zone from different subscription along with existing DNS zone.

  # diff_sub = true
  # alias                                         = ""
  # alias_sub                                     = ""

  #########Following to be uncommmented when using DNS zone from different resource group or different subscription.
  # existing_private_dns_zone                     = "privatelink.blob.core.windows.net"
  # existing_private_dns_zone_resource_group_name = "dns-rg"



  ##   Storage Container
  containers_list = [
    { name = "app-test", access_type = "private" },
  ]
  tables = ["table1"]
  queues = ["queue1"]
  file_shares = [
    { name = "fileshare", quota = "10" },
  ]

  virtual_network_id         = module.vnet.vnet_id
  subnet_id                  = module.subnet.default_subnet_id[0]
  log_analytics_workspace_id = module.log-analytics.workspace_id
}
