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
  source                        = "../.."
  name                          = local.name
  environment                   = local.environment
  default_enabled               = true
  resource_group_name           = "app-test-rg"
  location                      = "Central India"
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
  virtual_network_id         = "/subscriptions/--------------<vnet_id>---------------"
  subnet_id                  = "/subscriptions/--------------<subnet_id>---------------"
  log_analytics_workspace_id = "/subscriptions/--------------<log_analytics_workspace_id>---------------"
}
