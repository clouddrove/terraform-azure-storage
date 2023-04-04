
data "azurerm_client_config" "current" {}

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
  count                             = var.enabled && var.cmk_encryption_enabled ? 1 : 0
  depends_on                        = [azurerm_role_assignment.identity_assigned]
  name                              = var.storage_account_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_kind                      = var.account_kind
  account_tier                      = var.account_tier
  access_tier                       = var.access_tier
  account_replication_type          = var.account_replication_type
  enable_https_traffic_only         = var.enable_https_traffic_only
  min_tls_version                   = var.min_tls_version
  is_hns_enabled                    = var.is_hns_enabled
  sftp_enabled                      = var.sftp_enabled
  shared_access_key_enabled         = var.shared_access_key_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  default_to_oauth_authentication   = var.default_to_oauth_authentication
  cross_tenant_replication_enabled  = var.cross_tenant_replication_enabled
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public
  tags                              = module.labels.tags
  blob_properties {
    delete_retention_policy {
      days = var.soft_delete_retention
    }
    versioning_enabled       = var.versioning_enabled
    last_access_time_enabled = var.last_access_time_enabled
  }
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" ? [join("", azurerm_user_assigned_identity.identity.*.id)] : null
    }
  }
  dynamic "customer_managed_key" {
    for_each = var.cmk_encryption_enabled ? [1] : []
    content {
      key_vault_key_id          = var.cmk_encryption_enabled ? join("", azurerm_key_vault_key.kvkey.*.id) : null
      user_assigned_identity_id = var.cmk_encryption_enabled ? join("", azurerm_user_assigned_identity.identity.*.id) : null
    }
  }
}

resource "azurerm_storage_account" "default_storage" {
  count                             = var.enabled && var.default_enabled ? 1 : 0
  name                              = var.storage_account_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_kind                      = var.account_kind
  account_tier                      = var.account_tier
  access_tier                       = var.access_tier
  account_replication_type          = var.account_replication_type
  enable_https_traffic_only         = var.enable_https_traffic_only
  min_tls_version                   = var.min_tls_version
  is_hns_enabled                    = var.is_hns_enabled
  sftp_enabled                      = var.sftp_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  default_to_oauth_authentication   = var.default_to_oauth_authentication
  cross_tenant_replication_enabled  = var.cross_tenant_replication_enabled
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public
  tags                              = module.labels.tags
  blob_properties {
    delete_retention_policy {
      days = var.soft_delete_retention
    }
    versioning_enabled       = var.versioning_enabled
    last_access_time_enabled = var.last_access_time_enabled
  }

}
resource "azurerm_user_assigned_identity" "identity" {
  count               = var.cmk_encryption_enabled ? 1 : 0
  location            = var.location
  name                = format("midd-storage-%s", module.labels.id)
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "identity_assigned" {
  depends_on           = [azurerm_user_assigned_identity.identity]
  count                = var.cmk_encryption_enabled ? 1 : 0
  principal_id         = join("", azurerm_user_assigned_identity.identity.*.principal_id)
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

resource "azurerm_key_vault_key" "kvkey" {
  count        = var.cmk_encryption_enabled ? 1 : 0
  name         = format("cmk-%s", module.labels.id)
  key_vault_id = var.key_vault_id
  key_type     = "RSA"
  key_size     = 2048
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

# Network Rules
resource "azurerm_storage_account_network_rules" "network-rules" {
  for_each                   = { for rule in var.network_rules : rule.default_action => rule }
  storage_account_id         = var.cmk_encryption_enabled ? join("", azurerm_storage_account.storage.*.id) : join("", azurerm_storage_account.default_storage.*.id)
  default_action             = lookup(each.value, "default_action", "Deny")
  ip_rules                   = lookup(each.value, "ip_rules", null)
  virtual_network_subnet_ids = lookup(each.value, "virtual_network_subnet_ids", null)
  bypass                     = lookup(each.value, "bypass", null)
}

## Storage Account Threat Protection
resource "azurerm_advanced_threat_protection" "atp" {
  target_resource_id = var.cmk_encryption_enabled ? join("", azurerm_storage_account.storage.*.id) : join("", azurerm_storage_account.default_storage.*.id)
  enabled            = var.enable_advanced_threat_protection
}

resource "azurerm_key_vault_access_policy" "example" {
  count        = var.cmk_encryption_enabled ? length(var.object_id) : 0
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = element(var.object_id, count.index)

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "Get",
    "WrapKey",
    "UnwrapKey",
    "List",
    "Decrypt",
    "Sign",
    "Encrypt"
  ]
  secret_permissions = [
    "Get",
  ]
}

## Storage Container
resource "azurerm_storage_container" "container" {
  count                 = length(var.containers_list)
  name                  = var.containers_list[count.index].name
  storage_account_name  = var.cmk_encryption_enabled ? join("", azurerm_storage_account.storage.*.name) : join("", azurerm_storage_account.default_storage.*.name)
  container_access_type = var.containers_list[count.index].access_type
}

## Storage File Share
resource "azurerm_storage_share" "fileshare" {
  count                = length(var.file_shares)
  name                 = var.file_shares[count.index].name
  storage_account_name = var.cmk_encryption_enabled ? join("", azurerm_storage_account.storage.*.name) : join("", azurerm_storage_account.default_storage.*.name)
  quota                = var.file_shares[count.index].quota
}

## Storage Tables
resource "azurerm_storage_table" "tables" {
  count                = length(var.tables)
  name                 = var.tables[count.index]
  storage_account_name = var.cmk_encryption_enabled ? join("", azurerm_storage_account.storage.*.name) : join("", azurerm_storage_account.default_storage.*.name)
}

## Storage Queues
resource "azurerm_storage_queue" "queues" {
  count                = length(var.queues)
  name                 = var.queues[count.index]
  storage_account_name = var.cmk_encryption_enabled ? join("", azurerm_storage_account.storage.*.name) : join("", azurerm_storage_account.default_storage.*.name)
}

## Management Policies
resource "azurerm_storage_management_policy" "lifecycle_management" {
  count              = var.management_policy_enable ? length(var.management_policy) : 0
  storage_account_id = var.cmk_encryption_enabled ? join("", azurerm_storage_account.storage.*.id) : join("", azurerm_storage_account.default_storage.*.id)

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

provider "azurerm" {
  alias = "peer"
  features {}
  subscription_id = var.alias_sub
}

resource "azurerm_private_endpoint" "pep" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = format("%s-pe-storage", module.labels.id)
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = var.subnet_id
  tags                = module.labels.tags
  private_service_connection {
    name                           = format("%s-psc-storage", module.labels.id)
    is_manual_connection           = false
    private_connection_resource_id = var.cmk_encryption_enabled ? join("", azurerm_storage_account.storage.*.id) : join("", azurerm_storage_account.default_storage.*.id)
    subresource_names              = ["blob"]
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

locals {
  resource_group_name   = var.resource_group_name
  location              = var.location
  valid_rg_name         = var.existing_private_dns_zone == null ? local.resource_group_name : (var.existing_private_dns_zone_resource_group_name == "" ? local.resource_group_name : var.existing_private_dns_zone_resource_group_name)
  private_dns_zone_name = var.existing_private_dns_zone == null ? join("", azurerm_private_dns_zone.dnszone.*.name) : var.existing_private_dns_zone
}

data "azurerm_private_endpoint_connection" "private-ip-0" {
  count               = var.enabled && var.enable_private_endpoint && var.cmk_encryption_enabled ? 1 : 0
  name                = join("", azurerm_private_endpoint.pep.*.name)
  resource_group_name = local.resource_group_name
  depends_on          = [azurerm_storage_account.storage]
}

data "azurerm_private_endpoint_connection" "private-ip-1" {
  count               = var.enabled && var.enable_private_endpoint && var.default_enabled ? 1 : 0
  name                = join("", azurerm_private_endpoint.pep.*.name)
  resource_group_name = local.resource_group_name
  depends_on          = [azurerm_storage_account.default_storage]
}

resource "azurerm_private_dns_zone" "dnszone" {
  count               = var.enabled && var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = local.resource_group_name
  tags                = module.labels.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "vent-link" {
  count                 = var.enabled && var.enable_private_endpoint && (var.existing_private_dns_zone != null ? (var.existing_private_dns_zone_resource_group_name == "" ? false : true) : true) && var.diff_sub == false ? 1 : 0
  name                  = var.existing_private_dns_zone == null ? format("%s-pdz-vnet-link-storage", module.labels.id) : format("%s-pdz-vnet-link-storage-1", module.labels.id)
  resource_group_name   = local.valid_rg_name
  private_dns_zone_name = local.private_dns_zone_name
  virtual_network_id    = var.virtual_network_id
  tags                  = module.labels.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "vent-link-1" {
  provider              = azurerm.peer
  count                 = var.enabled && var.enable_private_endpoint && var.diff_sub == true ? 1 : 0
  name                  = var.existing_private_dns_zone == null ? format("%s-pdz-vnet-link-storage", module.labels.id) : format("%s-pdz-vnet-link-storage-1", module.labels.id)
  resource_group_name   = local.valid_rg_name
  private_dns_zone_name = local.private_dns_zone_name
  virtual_network_id    = var.virtual_network_id
  tags                  = module.labels.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "addon_vent_link" {
  count                 = var.enabled && var.addon_vent_link ? 1 : 0
  name                  = format("%s-pdz-vnet-link-storage-addon", module.labels.id)
  resource_group_name   = var.addon_resource_group_name
  private_dns_zone_name = var.existing_private_dns_zone == null ? join("", azurerm_private_dns_zone.dnszone.*.name) : var.existing_private_dns_zone
  virtual_network_id    = var.addon_virtual_network_id
  tags                  = module.labels.tags
}

resource "azurerm_private_dns_a_record" "arecord" {
  count               = var.enabled && var.enable_private_endpoint && var.diff_sub == false ? 1 : 0
  name                = var.cmk_encryption_enabled ? join("", azurerm_storage_account.storage.*.name) : join("", azurerm_storage_account.default_storage.*.name)
  zone_name           = local.private_dns_zone_name
  resource_group_name = local.valid_rg_name
  ttl                 = 3600
  records             = var.cmk_encryption_enabled ? [data.azurerm_private_endpoint_connection.private-ip-0.0.private_service_connection.0.private_ip_address] : [data.azurerm_private_endpoint_connection.private-ip-1.0.private_service_connection.0.private_ip_address]
  tags                = module.labels.tags
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
resource "azurerm_private_dns_a_record" "arecord1" {
  count               = var.enabled && var.enable_private_endpoint && var.diff_sub == true ? 1 : 0
  provider            = azurerm.peer
  name                = var.cmk_encryption_enabled ? join("", azurerm_storage_account.storage.*.name) : join("", azurerm_storage_account.default_storage.*.name)
  zone_name           = local.private_dns_zone_name
  resource_group_name = local.valid_rg_name
  ttl                 = 3600
  records             = var.cmk_encryption_enabled ? [data.azurerm_private_endpoint_connection.private-ip-0.0.private_service_connection.0.private_ip_address] : [data.azurerm_private_endpoint_connection.private-ip-1.0.private_service_connection.0.private_ip_address]
  tags                = module.labels.tags
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage" {
  count                          = var.enable_diagnostic ? 1 : 0
  name                           = format("storage-diagnostic-log")
  target_resource_id             = var.default_enabled ? azurerm_storage_account.default_storage[0].id : azurerm_storage_account.storage[0].id # "${azurerm_storage_account.default_storage[0].id}/blobServices/default/" : "${azurerm_storage_account.storage[0].id}/blobServices/default/" # "${azurerm_storage_account.core.id}/blobServices/default/"
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  dynamic "metric" {
    for_each = var.metrics
    content {
      category = metric.value
      enabled  = var.metrics_enabled[count.index]
      retention_policy {
        days    = var.days
        enabled = var.retention_policy_enabled
      }
    }
  }

}

resource "azurerm_monitor_diagnostic_setting" "datastorage" {
  count                          = var.enable_diagnostic ? length(var.datastorages) : 0
  name                           = format("%s-diagnostic-log", var.datastorages[count.index])
  target_resource_id             = var.default_enabled ? "${azurerm_storage_account.default_storage[0].id}/${var.datastorages[count.index]}Services/default" : "${azurerm_storage_account.storage[0].id}/${var.datastorages[count.index]}Services/default" #  "${azurerm_storage_account.core.id}/blobServices/default/"
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  dynamic "log" {
    for_each = var.logs
    content {
      category = log.value
      enabled  = true
      retention_policy {
        days    = var.days
        enabled = var.retention_policy_enabled
      }
    }
  }

  dynamic "metric" {
    for_each = var.metrics
    content {
      category = metric.value
      enabled  = true
      retention_policy {
        days    = var.days
        enabled = var.retention_policy_enabled
      }
    }
  }

}
