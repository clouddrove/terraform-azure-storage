
module "labels" {
  source      = "clouddrove/labels/azure"
  version     = "1.0.0"
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

resource "azurerm_storage_account" "storage" {
  count                     = var.enabled ? 1 : 0
  name                      = var.storage_account_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_kind              = var.account_kind
  account_tier              = var.account_tier
  access_tier               = var.access_tier
  account_replication_type  = var.account_replication_type
  enable_https_traffic_only = var.enable_https_traffic_only
  min_tls_version           = var.min_tls_version
  is_hns_enabled            = var.is_hns_enabled
  sftp_enabled              = var.sftp_enabled
  tags                      = module.labels.tags
  blob_properties {
    delete_retention_policy {
      days = var.soft_delete_retention
    }
  }

}

# Network Rules
resource "azurerm_storage_account_network_rules" "network-rules" {
  for_each                   = { for rule in var.network_rules : rule.default_action => rule }
  storage_account_id         = join("", azurerm_storage_account.storage.*.id)
  default_action             = lookup(each.value, "default_action", "Deny")
  ip_rules                   = lookup(each.value, "ip_rules", null)
  virtual_network_subnet_ids = lookup(each.value, "virtual_network_subnet_ids", null)
  bypass                     = lookup(each.value, "bypass", null)
}

## Storage Account Threat Protection
resource "azurerm_advanced_threat_protection" "atp" {
  target_resource_id = join("", azurerm_storage_account.storage.*.id)
  enabled            = var.enable_advanced_threat_protection
}

## Storage Container
resource "azurerm_storage_container" "container" {
  count                 = length(var.containers_list)
  name                  = var.containers_list[count.index].name
  storage_account_name  = join("", azurerm_storage_account.storage.*.name)
  container_access_type = var.containers_list[count.index].access_type
}

## Storage File Share
resource "azurerm_storage_share" "fileshare" {
  count                = length(var.file_shares)
  name                 = var.file_shares[count.index].name
  storage_account_name = join("", azurerm_storage_account.storage.*.name)
  quota                = var.file_shares[count.index].quota
}

## Storage Tables
resource "azurerm_storage_table" "tables" {
  count                = length(var.tables)
  name                 = var.tables[count.index]
  storage_account_name = join("", azurerm_storage_account.storage.*.name)
}

## Storage Queues
resource "azurerm_storage_queue" "queues" {
  count                = length(var.queues)
  name                 = var.queues[count.index]
  storage_account_name = join("", azurerm_storage_account.storage.*.name)
}

## Management Policies 

resource "azurerm_storage_management_policy" "lifecycle_management" {
  count              = length(var.management_policy) == 0 ? 0 : 1
  storage_account_id = join("", azurerm_storage_account.storage.*.id)

  dynamic "rule" {
    for_each = var.management_policy
    iterator = it
    content {
      name    = "rule${it.key}"
      enabled = true
      filters {
        prefix_match = it.value.prefix_match
        blob_types   = ["blockBlob"]
      }
      actions {
        base_blob {
          tier_to_cool_after_days_since_modification_greater_than    = it.value.tier_to_cool_after_days
          tier_to_archive_after_days_since_modification_greater_than = it.value.tier_to_archive_after_days
          delete_after_days_since_modification_greater_than          = it.value.delete_after_days
        }
        snapshot {
          delete_after_days_since_creation_greater_than = it.value.snapshot_delete_after_days
        }
      }
    }
  }
}