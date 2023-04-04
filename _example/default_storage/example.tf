# Azure Provider configuration
provider "azurerm" {
  features {}
}

## Resource Group
module "resource_group" {
  source = "clouddrove/resource-group/azure"

  label_order = ["name", "environment", ]
  name        = "appe"
  environment = "test"
  location    = "North Europe"
}

#Vnet
module "vnet" {
  source  = "clouddrove/vnet/azure"
  version = "1.0.1"

  name                = "app"
  environment         = "test"
  label_order         = ["name", "environment"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
}

###subnet
module "subnet" {
  source  = "clouddrove/subnet/azure"
  version = "1.0.2"

  name                 = "app"
  environment          = "test"
  label_order          = ["name", "environment"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = join("", module.vnet.vnet_name)

  #subnet
  subnet_names    = ["subnet1"]
  subnet_prefixes = ["10.0.1.0/24"]

  # route_table
  enable_route_table = false
  routes = [
    {
      name           = "rt-test"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
}

module "log-analytics" {
  source                           = "clouddrove/log-analytics/azure"
  version                          = "1.0.1"
  name                             = "app"
  environment                      = "test"
  label_order                      = ["name", "environment"]
  create_log_analytics_workspace   = true
  log_analytics_workspace_sku      = "PerGB2018"
  daily_quota_gb                   = "-1"
  internet_ingestion_enabled       = true
  internet_query_enabled           = true
  resource_group_name              = module.resource_group.resource_group_name
  log_analytics_workspace_location = module.resource_group.resource_group_location
}


##    Storage Account
module "storage" {
  source               = "../.."
  name                 = "app"
  environment          = "test"
  label_order          = ["name", "environment"]
  default_enabled      = true
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  storage_account_name = "storageppwe"

  network_rules = [
    {
      default_action = "Deny"
      ip_rules       = ["0.0.0.0/0"]
      bypass         = ["AzureServices"]
    }
  ]

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
  management_policy = [
    {
      prefix_match               = ["app-test/folder_path"]
      tier_to_cool_after_days    = 0
      tier_to_archive_after_days = 50
      delete_after_days          = 100
      snapshot_delete_after_days = 30
    }
  ]

  ####enable private endpoint
  virtual_network_id = module.vnet.vnet_id[0]
  subnet_id          = module.subnet.default_subnet_id[0]

  #### enable diagnostic setting
  enable_diagnostic          = true
  log_analytics_workspace_id = module.log-analytics.workspace_id
  metrics                    = ["Transaction", "Capacity"]
  metrics_enabled            = [true, true]

  datastorages = ["blob", "queue", "table", "file"]
  logs         = ["StorageWrite", "StorageRead", "StorageDelete"]
  logs_enabled = [true, true]

}
