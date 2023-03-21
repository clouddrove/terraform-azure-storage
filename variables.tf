#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "repository" {
  type        = string
  default     = ""
  description = "Terraform current module repo"
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] ."
}

variable "managedby" {
  type        = string
  default     = ""
  description = "ManagedBy, eg 'Identos'."
}

variable "enabled" {
  type        = bool
  description = "Set to false to prevent the module from creating any resources."
  default     = true
}

variable "default_enabled" {
  type        = bool
  description = "Set to false to prevent the module from creating any resources."
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  type        = string
  default     = ""
  description = "A container that holds related resources for an Azure solution"
}

variable "location" {
  type        = string
  default     = "North Europe"
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
}

variable "storage_account_name" {
  type        = string
  default     = ""
  description = "The name of the azure storage account"
}

variable "account_tier" {
  type        = string
  default     = "Standard"
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created."
}

variable "access_tier" {
  default     = "Hot"
  description = "Defines the access tier for BlobStorage and StorageV2 accounts. Valid options are Hot and Cool."
}

variable "account_replication_type" {
  type        = string
  default     = ""
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created when types LRS, GRS and RAGRS are changed to ZRS, GZRS or RAGZRS and vice versa."
}

variable "enable_https_traffic_only" {
  type        = bool
  default     = true
  description = " Boolean flag which forces HTTPS if enabled, see here for more information."
}

variable "account_kind" {
  type        = string
  default     = "StorageV2"
  description = "The type of storage account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
}

variable "min_tls_version" {
  type        = string
  default     = "TLS1_2"
  description = "The minimum supported TLS version for the storage account"
}

variable "soft_delete_retention" {
  type        = number
  default     = 30
  description = "Number of retention days for soft delete. If set to null it will disable soft delete all together."
}

variable "containers_list" {
  type        = list(object({ name = string, access_type = string }))
  default     = []
  description = "List of containers to create and their access levels."
}

variable "network_rules" {
  default     = {}
  description = "List of objects that represent the configuration of each network rules."
}

variable "is_hns_enabled" {
  description = "Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "sftp_enabled" {
  description = "Boolean, enable SFTP for the storage account"
  type        = bool
  default     = false
}

variable "enable_advanced_threat_protection" {
  description = "Boolean flag which controls if advanced threat protection is enabled."
  default     = false
  type        = bool
}

variable "file_shares" {
  description = "List of containers to create and their access levels."
  type        = list(object({ name = string, quota = number }))
  default     = []
}

variable "tables" {
  description = "List of storage tables."
  type        = list(string)
  default     = []
}

variable "queues" {
  description = "List of storages queues"
  type        = list(string)
  default     = []
}

variable "management_policy" {
  description = "Configure Azure Storage firewalls and virtual networks"
  type = list(object({
    prefix_match               = set(string),
    tier_to_cool_after_days    = number,
    tier_to_archive_after_days = number,
    delete_after_days          = number,
    snapshot_delete_after_days = number
  }))
  default = []
}

variable "user_assigned_identity_id" {
  type        = string
  default     = null
  description = " The ID of a user assigned identity."
}
# Identity
variable "identity_type" {
  description = "Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both)."
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Storage Account."
  type        = list(string)
  default     = null
}
variable "key_vault_id" {
  type    = string
  default = null
}
variable "principal_id" {
  type        = list(string)
  default     = []
  description = " The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to. Changing this forces a new resource to be created."
}
variable "cmk_encryption_enabled" {
  type    = bool
  default = false
}
variable "shared_access_key_enabled" {
  type        = bool
  default     = true
  description = " Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). The default value is true."
}
variable "infrastructure_encryption_enabled" {
  type        = bool
  default     = false
  description = " Is infrastructure encryption enabled? Changing this forces a new resource to be created. Defaults to false."
}
variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Whether the public network access is enabled? Defaults to true."
}
variable "default_to_oauth_authentication" {
  type        = bool
  default     = false
  description = "Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account. The default value is false"
}
variable "cross_tenant_replication_enabled" {
  type        = bool
  default     = true
  description = "Should cross Tenant replication be enabled? Defaults to true."
}
variable "allow_nested_items_to_be_public" {
  type        = bool
  default     = true
  description = "Allow or disallow nested items within this Account to opt into being public. Defaults to true."
}

variable "object_id" {
  type    = list(string)
  default = []
}

## Private endpoint

variable "virtual_network_id" {
  type        = string
  default     = ""
  description = "The name of the virtual network"
}

variable "subnet_id" {
  type        = string
  default     = ""
  description = "The resource ID of the subnet"
}

variable "enable_private_endpoint" {
  type        = bool
  default     = false
  description = "enable or disable private endpoint to storage account"
}

variable "existing_private_dns_zone" {
  type        = string
  default     = null
  description = "Name of the existing private DNS zone"
}

variable "existing_private_dns_zone_resource_group_name" {
  type        = string
  default     = ""
  description = "The name of the existing resource group"
}

## Addon vritual link
variable "addon_vent_link" {
  type        = bool
  default     = false
  description = "The name of the addon vnet "
}

variable "addon_resource_group_name" {
  type        = string
  default     = ""
  description = "The name of the addon vnet resource group"
}

variable "addon_virtual_network_id" {
  type        = string
  default     = ""
  description = "The name of the addon vnet link vnet id"
}

variable "versioning_enabled" {
  type        = bool
  default     = false
  description = "Is versioning enabled? Default to false."
}

variable "last_access_time_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Is the last access time based tracking enabled? Default to true."
}

# Diagnosis Settings Enable

variable "enable_diagnostic" {
  type        = bool
  default     = false
  description = "Set to false to prevent the module from creating the diagnosys setting for the NSG Resource.."
}

variable "storage_account_id" {
  type        = string
  default     = null
  description = "Storage account id to pass it to destination details of diagnosys setting of NSG."
}

variable "eventhub_name" {
  type        = string
  default     = null
  description = "Eventhub Name to pass it to destination details of diagnosys setting of NSG."
}

variable "eventhub_authorization_rule_id" {
  type        = string
  default     = null
  description = "Eventhub authorization rule id to pass it to destination details of diagnosys setting of NSG."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "log analytics workspace id to pass it to destination details of diagnosys setting of NSG."
}

variable "retention_policy_enabled" {
  type        = bool
  default     = false
  description = "Set to false to prevent the module from creating retension policy for the diagnosys setting."
}

variable "days" {
  type        = number
  default     = 365
  description = "Number of days to create retension policies for te diagnosys setting."
}

variable "metrics" {
  type    = list(string)
  default = null
}

variable "metrics_enabled" {
  type    = list(bool)
  default = null
}

variable "logs" {
  type    = list(string)
  default = null
}

variable "logs_enabled" {
  type    = list(bool)
  default = null
}

variable "datastorages" {
  type    = list(string)
  default = null
}

variable "alias_sub" {
  type    = string
  default = null
}

variable "diff_sub" {
  type        = bool
  default     = false
  description = "The name of the addon vnet "
}

variable "alias" {
  type    = string
  default = null
}
variable "management_policy_enable" {
  type    = bool
  default = false
}
