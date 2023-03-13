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

module "log-analytics" {
  source                           = "clouddrove/log-analytics/azure"
  version                          = "1.0.0"
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
  depends_on                = [module.resource_group]
  source                    = "../.."
  default_enabled           = true
  resource_group_name       = module.resource_group.resource_group_name
  location                  = module.resource_group.resource_group_location
  storage_account_name      = "storagestartac"
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  enable_https_traffic_only = true
  is_hns_enabled            = true
  sftp_enabled              = true

  network_rules = [
    {
      default_action = "Deny"
      ip_rules       = ["0.0.0.0/0"]
      bypass         = ["AzureServices"]
    }
  ]


  ##   Storage Account Threat Protection
  enable_advanced_threat_protection = false

  ##   Storage Container
  containers_list = [
    { name = "app-test", access_type = "private" },
  ]

  ##   Storage File Share
  file_shares = [
    { name = "fileshare1", quota = 5 },
  ]

  ##   Storage Tables
  tables = ["table1"]

  ## Storage Queues
  queues = ["queue1"]

  management_policy = [
    {
      prefix_match               = ["app-test/folder_path"]
      tier_to_cool_after_days    = 0
      tier_to_archive_after_days = 50
      delete_after_days          = 100
      snapshot_delete_after_days = 30
    }
  ]

  #enable private endpoint
  # enabled_private_endpoint = true
  # subnet_id = ""
  # virtual_network_id = ""

  enable_diagnostic          = true
  log_analytics_workspace_id = module.log-analytics.workspace_id
  metrics                    = ["Transaction", "Capacity"]
  metrics_enabled            = [true, false]

  datastorages = ["blob", "queue", "table", "file"]
  logs         = ["StorageWrite", "StorageRead", "StorageDelete"]
  logs_enabled = [true, true]

}
