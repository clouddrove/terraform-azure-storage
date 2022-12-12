# Azure Provider configuration
provider "azurerm" {
  features {}
}

module "resource_group" {
  source = "clouddrove/resource-group/azure"

  label_order = ["name", "environment", ]
  name        = "app"
  environment = "test"
  location    = "North Europe"
}

module "storage" {
  depends_on               = [module.resource_group]
  source                   = "./.././"
  resource_group_name      = module.resource_group.resource_group_name
  storage_account_name     = "storagestartac"
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true
  sftp_enabled             = true
  network_rules = [
    {
    ip_rules = ["0.0.0.0/0"]
    bypass  = ["AzureServices"]
   }
  ]

  containers_list = [
    { name = "mystore250", access_type = "private" },
  ]
}
