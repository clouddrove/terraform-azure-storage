# Azure Provider configuration
provider "azurerm" {
  features {}
}

## Resource Group
module "resource_group" {
  source = "clouddrove/resource-group/azure"

  label_order = ["name", "environment", ]
  name        = "app"
  environment = "testing"
  location    = "North Europe"
}

##    Storage Account
module "storage" {
  depends_on                = [module.resource_group]
  source                    = "../"
  resource_group_name       = module.resource_group.resource_group_name
  storage_account_name      = "storagestartac"
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  enable_https_traffic_only = true
  is_hns_enabled            = true
  sftp_enabled              = true
  network_rules = [
    {
      ip_rules = ["0.0.0.0/0"]
      bypass   = ["AzureServices"]
    }
  ]

  ##   Storage Account Threat Protection
  enable_advanced_threat_protection = true

  ##   Storage Container
  containers_list = [
    { name = "mystore250", access_type = "private" },
  ]

  ##   Storage File Share
  file_shares = [
    { name = "fileshare1", quota = 5 },
  ]

  ##   Storage Tables
  tables = ["table1"]

  ## Storage Queues
  queues = ["queue1"]


}
