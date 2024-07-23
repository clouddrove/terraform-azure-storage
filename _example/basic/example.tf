provider "azurerm" {
  features {}
}


locals {
  name        = "app"
  environment = "test"
  label_order = ["name", "environment"]
}

##----------------------------------------------------------------------------- 
## Storage module call.
## Here default storage will be deployed i.e. storage account without cmk encryption. 
##-----------------------------------------------------------------------------
module "storage" {
  providers = {
    azurerm.main_sub = azurerm
  }
  source                        = "../.."
  name                          = local.name
  environment                   = local.environment
  label_order                   = local.label_order
  resource_group_name           = "test-rg"
  location                      = "Central India"
  storage_account_name          = "storage7386"
  public_network_access_enabled = true
  account_kind                  = "StorageV2"
  account_tier                  = "Standard"
  account_replication_type      = "GRS"

  ## Encryption is not enabled for this Storage account
  cmk_encryption_enabled = false

  ##   Storage Container
  containers_list = [
    { name = "app-test", access_type = "private" },
  ]
  tables = ["table1"]
  queues = ["queue1"]
  file_shares = [
    { name = "fileshare", quota = "10" },
  ]

  virtual_network_id         = "/subscriptions/--------------<vnet_id>---------------"
  subnet_id                  = "/subscriptions/--------------<subnet_id>---------------"
  log_analytics_workspace_id = "/subscriptions/--------------<log_analytics_workspace_id>---------------"
}
