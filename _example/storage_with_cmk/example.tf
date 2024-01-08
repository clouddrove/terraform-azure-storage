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
  location    = "East US 2"
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

  #subnet
  subnet_names    = ["subnet1"]
  subnet_prefixes = ["10.0.1.0/24"]

}

##----------------------------------------------------------------------------- 
## Key Vault module call. 
## Key Vault in encryption key will be stored.
##-----------------------------------------------------------------------------
module "vault" {
  depends_on          = [module.resource_group, module.vnet]
  source              = "clouddrove/key-vault/azure"
  version             = "1.0.5"
  name                = "appdvgcyus23654"
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  virtual_network_id  = module.vnet.vnet_id[0]
  subnet_id           = module.subnet.default_subnet_id[0]
  ##RBAC
  enable_rbac_authorization = true
  principal_id              = ["71d1aXXXXXXXXXXXXXXXXX166d7c97", ]
  role_definition_name      = ["Key Vault Administrator", ]
  #### enable diagnostic setting
  diagnostic_setting_enable  = true
  log_analytics_workspace_id = module.log-analytics.workspace_id ## when diagnostic_setting_enable = true, need to add log analytics workspace id
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
  label_order                      = ["name", "environment"]
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
## Here cmk storage will be deployed i.e. storage account with cmk encryption. 
##-----------------------------------------------------------------------------
module "storage" {
  source                   = "../.."
  name                     = local.name
  environment              = local.environment
  label_order              = local.label_order
  resource_group_name      = module.resource_group.resource_group_name
  location                 = module.resource_group.resource_group_location
  storage_account_name     = "storagkqp0896"
  account_kind             = "BlockBlobStorage"
  account_tier             = "Premium"
  identity_type            = "UserAssigned"
  object_id                = ["71dXXXXXXXXXXXXXXXXXXXX11c97", ]
  account_replication_type = "ZRS"
  ###customer_managed_key can only be set when the account_kind is set to StorageV2 or account_tier set to Premium, and the identity type is UserAssigned.
  key_vault_id = module.vault.id
  ##   Storage Container
  containers_list = [
    { name = "app-test", access_type = "private" },
  ]
  virtual_network_id         = module.vnet.vnet_id[0]
  subnet_id                  = module.subnet.default_subnet_id[0]
  log_analytics_workspace_id = module.log-analytics.workspace_id
}
