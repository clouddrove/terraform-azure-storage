# Azure Provider configuration
provider "azurerm" {
  features {}
}

## Resource Group
module "resource_group" {
  source = "clouddrove/resource-group/azure"

  label_order = ["name", "environment", ]
  name        = "app3"
  environment = "test"
  location    = "East US 2"
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

#Key Vault
module "vault" {
  depends_on = [module.resource_group, module.vnet]
  source     = "clouddrove/key-vault/azure"
  version    = "1.0.4"

  name        = "app"
  environment = "test"
  label_order = ["name", "environment", ]

  resource_group_name = module.resource_group.resource_group_name

  purge_protection_enabled    = true
  enabled_for_disk_encryption = true

  virtual_network_id = module.vnet.vnet_id[0]
  subnet_id          = module.subnet.default_subnet_id[0]
  ##RBAC
  enable_rbac_authorization = true
  principal_id              = ["71d1aXXXXXXXXXXXXXXXXX166d7c97", ]
  role_definition_name      = ["Key Vault Administrator", ]

  #### enable diagnostic setting
  diagnostic_setting_enable  = true
  log_analytics_workspace_id = module.log-analytics.workspace_id ## when diagnostic_setting_enable = true, need to add log analytics workspace id
}


module "log-analytics" {
  source                           = "clouddrove/log-analytics/azure"
  version                          = "1.0.1"
  name                             = "app"
  environment                      = "test23"
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
  source                   = "../.."
  name                     = "app"
  environment              = "test"
  label_order              = ["name", "environment", ]
  resource_group_name      = module.resource_group.resource_group_name
  location                 = module.resource_group.resource_group_location
  storage_account_name     = "storagkistaptac"
  account_kind             = "BlockBlobStorage"
  account_tier             = "Premium"
  identity_type            = "UserAssigned"
  object_id                = ["71d1XXXXXXXXXXXXXXXXX7c97", "a9379eXXXXXXXXXXXXXXXa0ad6"]
  account_replication_type = "ZRS"

  #### when CMK encryption enable required key-vault id
  ###customer_managed_key can only be set when the account_kind is set to StorageV2 or account_tier set to Premium, and the identity type is UserAssigned.
  cmk_encryption_enabled = true
  key_vault_id           = module.vault.id
  ###This can only be true when account_kind is StorageV2 or when account_tier is Premium and account_kind is one of BlockBlobStorage or FileStorage.

  network_rules = [
    {
      default_action = "Allow"
      ip_rules       = ["0.0.0.0/0"]
      bypass         = ["AzureServices"]
    }
  ]

  ##   Storage Container
  containers_list = [
    { name = "app-test", access_type = "private" },
  ]

  management_policy_enable = false
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
  metrics_enabled            = [true, false]

  datastorages = ["blob", "queue", "table", "file"]
  logs         = ["StorageWrite", "StorageRead", "StorageDelete"]
  logs_enabled = [true, true]
}
