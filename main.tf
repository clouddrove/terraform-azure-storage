data "azurerm_resource_group" "default" {
  name = var.resource_group_name
}

locals {
  resource_group_name = data.azurerm_resource_group.default.name
  location            = data.azurerm_resource_group.default.location
}

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
  resource_group_name       = local.resource_group_name
  location                  = local.location
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

  dynamic "network_rules" {
    for_each = var.network_rules
    content {
      default_action             = "Deny"
      ip_rules                   = lookup(network_rules.value, "ip_rules", null )
      virtual_network_subnet_ids = lookup(network_rules.value, "virtual_network_subnet_ids", null )
      bypass                     = lookup(network_rules.value, "bypass", null)

    }
  }
}

## Storage Container Creation
resource "azurerm_storage_container" "container" {
  count                 = length(var.containers_list)
  name                  = var.containers_list[count.index].name
  storage_account_name  = join("", azurerm_storage_account.storage.*.name)
  container_access_type = var.containers_list[count.index].access_type
}







