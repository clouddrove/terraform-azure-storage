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
  description = "ManagedBy, eg ''."
}

variable "enabled" {
  type        = bool
  description = "Set to false to prevent the module from creating any resources."
  default     = true
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
  type        = list(any)
  default     = []
  description = "Network rules restricing access to the storage account."
}

variable "is_hns_enabled" {
  type = bool
  default = false
}

variable "sftp_enabled" {
  type = bool
  default = false
}
