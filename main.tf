data "azurerm_client_config" "current" {}

##----------------------------------------------------------------------------- 
## Labels module callled that will be used for naming and tags.   
##-----------------------------------------------------------------------------
module "labels" {
  source      = "clouddrove/labels/azure"
  version     = "1.0.0"
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
  extra_tags = var.extra_tags
}

##----------------------------------------------------------------------------- 
## Below resource will create Storage Account resource with custormer managed key encryption and its components.  
## To create storage account with cmk(customer managed key) encryption set 'var.default_enabled = false'. 
##-----------------------------------------------------------------------------
resource "azurerm_storage_account" "storage" {
  count                             = var.enabled ? 1 : 0
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
  large_file_share_enabled          = var.large_file_share_enabled
  edge_zone                         = var.edge_zone
  nfsv3_enabled                     = var.nfsv3_enabled
  table_encryption_key_type         = var.table_encryption_key_type
  queue_encryption_key_type         = var.queue_encryption_key_type
  allowed_copy_scope                = var.allowed_copy_scope
  tags                              = module.labels.tags
  dynamic "blob_properties" {
    for_each = (
      var.account_kind != "FileStorage" && (var.storage_blob_data_protection != null || var.storage_blob_cors_rule != null) ? [1] : []
    )
    content {
      change_feed_enabled      = var.nfsv3_enabled || var.sftp_enabled ? false : var.storage_blob_data_protection.change_feed_enabled
      versioning_enabled       = var.nfsv3_enabled || var.sftp_enabled ? false : var.storage_blob_data_protection.versioning_enabled
      last_access_time_enabled = var.nfsv3_enabled || var.sftp_enabled ? false : var.storage_blob_data_protection.last_access_time_enabled
      dynamic "cors_rule" {
        for_each = var.storage_blob_cors_rule != null ? [1] : []
        content {
          allowed_headers    = var.storage_blob_cors_rule.allowed_headers
          allowed_methods    = var.storage_blob_cors_rule.allowed_methods
          allowed_origins    = var.storage_blob_cors_rule.allowed_origins
          exposed_headers    = var.storage_blob_cors_rule.exposed_headers
          max_age_in_seconds = var.storage_blob_cors_rule.max_age_in_seconds
        }
      }
      dynamic "delete_retention_policy" {
        for_each = var.storage_blob_data_protection.delete_retention_policy_in_days > 0 ? [1] : []
        content {
          days = var.storage_blob_data_protection.delete_retention_policy_in_days
        }
      }
      dynamic "container_delete_retention_policy" {
        for_each = var.storage_blob_data_protection.container_delete_retention_policy_in_days > 0 ? [1] : []
        content {
          days = var.storage_blob_data_protection.container_delete_retention_policy_in_days
        }
      }
      dynamic "restore_policy" {
        for_each = var.restore_policy ? [1] : []
        content {
          days = var.storage_blob_data_protection.container_delete_retention_policy_in_days - 1
        }
      }
    }
  }
  dynamic "sas_policy" {
    for_each = var.enable_sas_policy ? var.sas_policy_settings : []
    content {
      expiration_period = sas_policy.value.expiration_period
      expiration_action = sas_policy.value.expiration_action
    }
  }
  dynamic "custom_domain" {
    for_each = var.custom_domain_name != null ? [1] : []
    content {
      name          = var.custom_domain_name
      use_subdomain = var.use_subdomain
    }
  }
  dynamic "static_website" {
    for_each = var.static_website_config != null ? [1] : []
    content {
      index_document     = var.static_website_config.index_document
      error_404_document = var.static_website_config.error_404_document
    }
  }
  dynamic "azure_files_authentication" {
    for_each = var.file_share_authentication != null ? [1] : []
    content {
      directory_type = var.file_share_authentication.directory_type
      dynamic "active_directory" {
        for_each = var.file_share_authentication.directory_type == "AD" ? [var.file_share_authentication.active_directory] : []
        iterator = ad
        content {
          storage_sid         = ad.value.storage_sid
          domain_name         = ad.value.domain_name
          domain_sid          = ad.value.domain_sid
          domain_guid         = ad.value.domain_guid
          forest_name         = ad.value.forest_name
          netbios_domain_name = ad.value.netbios_domain_name
        }
      }
    }
  }
  dynamic "routing" {
    for_each = var.enable_routing ? var.routing : []
    content {
      publish_internet_endpoints  = routing.value.publish_internet_endpoints
      publish_microsoft_endpoints = routing.value.publish_microsoft_endpoints
      choice                      = routing.value.choice
    }
  }
  dynamic "queue_properties" {
    for_each = var.queue_properties_logging != null && contains(["Storage", "StorageV2"], var.account_kind) ? [1] : []
    content {
      logging {
        delete                = var.queue_properties_logging.delete
        read                  = var.queue_properties_logging.read
        write                 = var.queue_properties_logging.write
        version               = var.queue_properties_logging.version
        retention_policy_days = var.queue_properties_logging.retention_policy_days
      }
      dynamic "hour_metrics" {
        for_each = var.enable_hour_metrics ? var.hour_metrics : {}
        content {
          enabled               = hour_metrics.value.enabled
          version               = hour_metrics.value.version
          include_apis          = hour_metrics.value.include_apis
          retention_policy_days = hour_metrics.value.retention_policy_days
        }
      }
      dynamic "minute_metrics" {
        for_each = var.enable_minute_metrics ? toset(var.minute_metrics) : []
        content {
          enabled               = minute_metrics.value.enabled
          version               = minute_metrics.value.version
          include_apis          = minute_metrics.value.include_apis
          retention_policy_days = minute_metrics.value.retention_policy_days
        }
      }
    }
  }
  dynamic "share_properties" {
    for_each = var.file_share_cors_rules != null && var.file_share_retention_policy_in_days != null && var.file_share_properties_smb != null ? [1] : []
    content {
      dynamic "cors_rule" {
        for_each = var.enable_file_share_cors_rules ? var.file_share_cors_rules : []
        content {
          allowed_headers    = file_share_cors_rules.value.allowed_headers
          allowed_methods    = file_share_cors_rules.value.allowed_methods
          allowed_origins    = file_share_cors_rules.value.allowed_origins
          exposed_headers    = file_share_cors_rules.value.exposed_headers
          max_age_in_seconds = file_share_cors_rules.value.max_age_in_seconds
        }
      }
      dynamic "retention_policy" {
        for_each = var.file_share_retention_policy_in_days != null ? [1] : []
        content {
          days = var.file_share_retention_policy_in_days
        }
      }
      dynamic "smb" {
        for_each = var.file_share_properties_smb != null ? [1] : []
        content {
          authentication_types            = var.file_share_properties_smb.authentication_types
          channel_encryption_type         = var.file_share_properties_smb.channel_encryption_type
          kerberos_ticket_encryption_type = var.file_share_properties_smb.kerberos_ticket_encryption_type
          versions                        = var.file_share_properties_smb.versions
          multichannel_enabled            = var.file_share_properties_smb.multichannel_enabled
        }
      }
    }
  }
  dynamic "identity" {
    for_each = var.cmk_encryption_enabled && var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" ? [join("", azurerm_user_assigned_identity.identity.*.id)] : null
    }
  }
  dynamic "customer_managed_key" {
    for_each = var.cmk_encryption_enabled ? [1] : []
    content {
      key_vault_key_id          = var.key_vault_id != null ? azurerm_key_vault_key.kvkey[0].id : null
      user_assigned_identity_id = var.key_vault_id != null ? azurerm_user_assigned_identity.identity[0].id : null
    }
  }
}

##----------------------------------------------------------------------------- 
## Below resource will create user assigned identity in your azure environment. 
## This user assigned identity will be created when storage account with cmk is created.    
##-----------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "identity" {
  count               = var.enabled && var.cmk_encryption_enabled ? 1 : 0
  location            = var.location
  name                = format("%s-storage-mid", module.labels.id)
  resource_group_name = var.resource_group_name
}

##----------------------------------------------------------------------------- 
## Below resource will assign 'Key Vault Crypto Service Encryption User' role to user assigned identity created above. 
##-----------------------------------------------------------------------------
resource "azurerm_role_assignment" "identity_assigned" {
  depends_on           = [azurerm_user_assigned_identity.identity]
  count                = var.enabled && var.cmk_encryption_enabled && var.key_vault_rbac_auth_enabled ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.identity[0].principal_id
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

##-----------------------------------------------------------------------------
## Below resource will provide user access on key vault based on role base access in azure environment.
## if rbac is enabled then below resource will create. 
##-----------------------------------------------------------------------------
resource "azurerm_role_assignment" "rbac_keyvault_crypto_officer" {
  for_each = toset(var.key_vault_rbac_auth_enabled && var.enabled && var.cmk_encryption_enabled ? var.admin_objects_ids : [])

  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = each.value
}

##----------------------------------------------------------------------------- 
## Below resource will create key vault key that will be used for encryption.  
##-----------------------------------------------------------------------------
resource "azurerm_key_vault_key" "kvkey" {
  depends_on      = [azurerm_role_assignment.identity_assigned, azurerm_role_assignment.rbac_keyvault_crypto_officer]
  count           = var.enabled && var.cmk_encryption_enabled ? 1 : 0
  name            = format("%s-storage-key-vault-key", module.labels.id)
  expiration_date = var.expiration_date
  key_vault_id    = var.key_vault_id
  key_type        = "RSA"
  key_size        = 2048
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  dynamic "rotation_policy" {
    for_each = var.rotation_policy_enabled ? var.rotation_policy : {}
    content {
      automatic {
        time_before_expiry = rotation_policy.value.time_before_expiry
      }

      expire_after         = rotation_policy.value.expire_after
      notify_before_expiry = rotation_policy.value.notify_before_expiry
    }
  }
}

##----------------------------------------------------------------------------- 
## Below resource will create network rules for storage account.  
##-----------------------------------------------------------------------------
resource "azurerm_storage_account_network_rules" "network-rules" {
  for_each                   = var.enabled ? { for rule in var.network_rules : rule.default_action => rule } : {}
  storage_account_id         = join("", azurerm_storage_account.storage.*.id)
  default_action             = lookup(each.value, "default_action", "Deny")
  ip_rules                   = lookup(each.value, "ip_rules", null)
  virtual_network_subnet_ids = lookup(each.value, "virtual_network_subnet_ids", null)
  bypass                     = lookup(each.value, "bypass", null)
  dynamic "private_link_access" {
    for_each = var.enable_private_link_access ? var.private_link_access : []
    content {
      endpoint_resource_id = private_link_access.value.endpoint_resource_id
      endpoint_tenant_id   = coalesce(private_link_access.value.endpoint_tenant_id, data.azuread_tenant.current.tenant_id)
    }
  }
}

##----------------------------------------------------------------------------- 
## Below resource will create threat protection for storage account. 
##-----------------------------------------------------------------------------
resource "azurerm_advanced_threat_protection" "atp" {
  count              = var.enabled && var.enable_advanced_threat_protection ? 1 : 0
  target_resource_id = join("", azurerm_storage_account.storage.*.id)
  enabled            = var.enable_advanced_threat_protection
}

##----------------------------------------------------------------------------- 
## Below resource will create access policy for user whose object id will be mentioned. 
## This resource is not required when key vault has role based authorization(rbac) enabled.  
##-----------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "keyvault-access-policy" {
  count        = var.enabled && var.key_vault_rbac_auth_enabled == false ? 1 : 0
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = join("", azurerm_user_assigned_identity.identity.*.principal_id)

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
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge",
  ]
  storage_permissions = [
    "Get",
    "List",
  ]
}

##----------------------------------------------------------------------------- 
## Below resource will create container in storage account.
##-----------------------------------------------------------------------------
resource "azurerm_storage_container" "container" {
  count                 = var.enabled ? length(var.containers_list) : 0
  name                  = var.containers_list[count.index].name
  storage_account_name  = azurerm_storage_account.storage[0].name
  container_access_type = var.containers_list[count.index].access_type
}

##----------------------------------------------------------------------------- 
## Below resource will create file share in storage account.  
##-----------------------------------------------------------------------------
resource "azurerm_storage_share" "fileshare" {
  count                = var.enabled ? length(var.file_shares) : 0
  name                 = var.file_shares[count.index].name
  storage_account_name = azurerm_storage_account.storage[0].name
  quota                = var.file_shares[count.index].quota
}

##----------------------------------------------------------------------------- 
## Below resource will create tables in storage account.  
##-----------------------------------------------------------------------------
resource "azurerm_storage_table" "tables" {
  count                = var.enabled ? length(var.tables) : 0
  name                 = var.tables[count.index]
  storage_account_name = join("", azurerm_storage_account.storage.*.name)
}

##----------------------------------------------------------------------------- 
## Below resource will create queue in storage account.  
##-----------------------------------------------------------------------------
resource "azurerm_storage_queue" "queues" {
  count                = var.enabled ? length(var.queues) : 0
  name                 = var.queues[count.index]
  storage_account_name = join("", azurerm_storage_account.storage.*.name)
}

##----------------------------------------------------------------------------- 
## Below resource will create management policy for storage account.  
##-----------------------------------------------------------------------------
resource "azurerm_storage_management_policy" "lifecycle_management" {
  count              = var.enabled && var.management_policy_enable ? length(var.management_policy) : 0
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

##----------------------------------------------------------------------------- 
## Provider block
## To be used only when there is existing private dns zone in different subscription. Mention other subscription id in 'var.alias_sub'. 
##-----------------------------------------------------------------------------
provider "azurerm" {
  alias = "peer"
  features {}
  subscription_id = var.alias_sub
}

##----------------------------------------------------------------------------- 
## Below resource will create private endpoint for storage account. 
##-----------------------------------------------------------------------------
resource "azurerm_private_endpoint" "pep" {
  count               = var.enabled && var.enable_private_endpoint ? 1 : 0
  name                = format("%s-%s-pe", module.labels.id, var.storage_account_name)
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = var.subnet_id
  tags                = module.labels.tags
  private_service_connection {
    name                           = format("%s-%s-psc", module.labels.id, var.storage_account_name)
    is_manual_connection           = false
    private_connection_resource_id = join("", azurerm_storage_account.storage.*.id)
    subresource_names              = ["blob"]
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

##----------------------------------------------------------------------------- 
## Locals declaration to determine the resource group in which exsisting private dns zone is present. 
##-----------------------------------------------------------------------------
locals {
  resource_group_name   = var.resource_group_name
  location              = var.location
  valid_rg_name         = var.existing_private_dns_zone == null ? local.resource_group_name : (var.existing_private_dns_zone_resource_group_name == "" ? local.resource_group_name : var.existing_private_dns_zone_resource_group_name)
  private_dns_zone_name = var.existing_private_dns_zone == null ? join("", azurerm_private_dns_zone.dnszone.*.name) : var.existing_private_dns_zone
}

##----------------------------------------------------------------------------- 
## Data block to retreive private ip of private endpoint.
## Will work when storage account with cmk encryption. 
##-----------------------------------------------------------------------------
data "azurerm_private_endpoint_connection" "private-ip-0" {
  count               = var.enabled && var.enable_private_endpoint ? 1 : 0
  name                = join("", azurerm_private_endpoint.pep.*.name)
  resource_group_name = local.resource_group_name
  depends_on          = [azurerm_storage_account.storage]
}

##----------------------------------------------------------------------------- 
## Below resource will create private dns zone in your azure subscription. 
## Will be created only when there is no existing private dns zone and private endpoint is enabled. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "dnszone" {
  count               = var.enabled && var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = local.resource_group_name
  tags                = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Below resource will create vnet link in private dns.
## Vnet link will be created when there is no existing private dns zone or existing private dns zone is in same subscription.  
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "vent-link" {
  count                 = var.enabled && var.enable_private_endpoint && (var.existing_private_dns_zone != null ? (var.existing_private_dns_zone_resource_group_name == "" ? false : true) : true) && var.diff_sub == false ? 1 : 0
  name                  = var.existing_private_dns_zone == null ? format("%s-pdz-vnet-link-storage", module.labels.id) : format("%s-pdz-vnet-link-storage-1", module.labels.id)
  resource_group_name   = local.valid_rg_name
  private_dns_zone_name = local.private_dns_zone_name
  virtual_network_id    = var.virtual_network_id
  tags                  = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Below resource will create vnet link in existing private dns zone. 
## Vnet link will be created when existing private dns zone is in different subscription. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "vent-link-1" {
  provider              = azurerm.peer
  count                 = var.enabled && var.enable_private_endpoint && var.diff_sub == true ? 1 : 0
  name                  = var.existing_private_dns_zone == null ? format("%s-pdz-vnet-link-storage", module.labels.id) : format("%s-pdz-vnet-link-storage-1", module.labels.id)
  resource_group_name   = local.valid_rg_name
  private_dns_zone_name = local.private_dns_zone_name
  virtual_network_id    = var.virtual_network_id
  tags                  = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Below resource will create vnet link in existing private dns zone. 
## Vnet link will be created when existing private dns zone is in different subscription. 
## This resource is deployed when more than 1 vnet link is required and module can be called again to do so without deploying other storage account resources. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "vent-link-diff-subs" {
  provider              = azurerm.peer
  count                 = var.enabled && var.multi_sub_vnet_link && var.existing_private_dns_zone != null ? 1 : 0
  name                  = format("%s-pdz-vnet-link-storage-1", module.labels.id)
  resource_group_name   = var.existing_private_dns_zone_resource_group_name
  private_dns_zone_name = var.existing_private_dns_zone
  virtual_network_id    = var.virtual_network_id
  tags                  = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Below resource will create vnet link in private dns zone. 
## Below resource will be created when extra vnet link is required in dns zone in same subscription. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "addon_vent_link" {
  count                 = var.enabled && var.addon_vent_link ? 1 : 0
  name                  = format("%s-pdz-vnet-link-storage-addon", module.labels.id)
  resource_group_name   = var.addon_resource_group_name
  private_dns_zone_name = var.existing_private_dns_zone == null ? join("", azurerm_private_dns_zone.dnszone.*.name) : var.existing_private_dns_zone
  virtual_network_id    = var.addon_virtual_network_id
  tags                  = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Below resource will create dns A record for private ip of private endpoint in private dns zone. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_a_record" "arecord" {
  count               = var.enabled && var.enable_private_endpoint && var.diff_sub == false ? 1 : 0
  name                = var.key_vault_id != null ? join("", azurerm_storage_account.storage.*.name) : null
  zone_name           = local.private_dns_zone_name
  resource_group_name = local.valid_rg_name
  ttl                 = 3600
  records             = [data.azurerm_private_endpoint_connection.private-ip-0.0.private_service_connection.0.private_ip_address]
  tags                = module.labels.tags
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

##----------------------------------------------------------------------------- 
## Below resource will create dns A record for private ip of private endpoint in private dns zone. 
## This resource will be created when private dns is in different subscription. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_a_record" "arecord1" {
  count               = var.enabled && var.enable_private_endpoint && var.diff_sub == true ? 1 : 0
  provider            = azurerm.peer
  name                = var.key_vault_id != null ? join("", azurerm_storage_account.storage.*.name) : null
  zone_name           = local.private_dns_zone_name
  resource_group_name = local.valid_rg_name
  ttl                 = 3600
  records             = [data.azurerm_private_endpoint_connection.private-ip-0.0.private_service_connection.0.private_ip_address]
  tags                = module.labels.tags
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

##----------------------------------------------------------------------------- 
## Below resources will create diagnostic setting for storage account and its components. 
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "storage" {
  count                          = var.enabled && var.enable_diagnostic ? 1 : 0
  name                           = format("storage-diagnostic-log")
  target_resource_id             = join("", azurerm_storage_account.storage.*.id)
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  dynamic "metric" {
    for_each = var.metrics
    content {
      category = metric.value
      enabled  = var.metrics_enabled[count.index]
    }
  }

}

resource "azurerm_monitor_diagnostic_setting" "datastorage" {
  depends_on                     = [azurerm_storage_account.storage]
  count                          = var.enabled && var.enable_diagnostic ? length(var.datastorages) : 0
  name                           = format("%s-diagnostic-log", var.datastorages[count.index])
  storage_account_id             = var.storage_account_id
  target_resource_id             = "${azurerm_storage_account.storage[0].id}/${var.datastorages[count.index]}Services/default"
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.logs
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = var.metrics
    content {
      category = metric.value
      enabled  = true
    }
  }

}

resource "azurerm_monitor_diagnostic_setting" "storage-nic" {
  depends_on                     = [azurerm_private_endpoint.pep]
  count                          = var.enabled && var.enable_diagnostic && var.enable_private_endpoint ? 1 : 0
  name                           = format("%s-storage-nic-diagnostic-log", module.labels.id)
  target_resource_id             = element(azurerm_private_endpoint.pep[count.index].network_interface.*.id, count.index)
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type
  metric {
    category = "AllMetrics"
    enabled  = var.Metric_enable
  }
  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}
