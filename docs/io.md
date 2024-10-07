## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| Metric\_enable | Is this Diagnostic Metric enabled? Defaults to true. | `bool` | `true` | no |
| access\_tier | Defines the access tier for BlobStorage and StorageV2 accounts. Valid options are Hot and Cool. | `string` | `"Hot"` | no |
| account\_kind | The type of storage account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. | `string` | `"StorageV2"` | no |
| account\_replication\_type | Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created when types LRS, GRS and RAGRS are changed to ZRS, GZRS or RAGZRS and vice versa. | `string` | `"LRS"` | no |
| account\_tier | Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created. | `string` | `"Standard"` | no |
| addon\_resource\_group\_name | The name of the addon vnet resource group | `string` | `null` | no |
| addon\_vent\_link | The name of the addon vnet | `bool` | `false` | no |
| addon\_virtual\_network\_id | The name of the addon vnet link vnet id | `string` | `null` | no |
| admin\_objects\_ids | IDs of the objects that can do all operations on all keys, secrets and certificates. | `list(string)` | `[]` | no |
| alias\_sub | n/a | `string` | `null` | no |
| allow\_nested\_items\_to\_be\_public | Allow or disallow nested items within this Account to opt into being public. Defaults to true. | `bool` | `false` | no |
| allowed\_copy\_scope | Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet. Possible values are AAD and PrivateLink. | `string` | `"PrivateLink"` | no |
| cmk\_encryption\_enabled | Whether to create CMK or not | `bool` | `false` | no |
| containers\_list | List of containers to create and their access levels. | `list(object({ name = string, access_type = string }))` | `[]` | no |
| cross\_tenant\_replication\_enabled | Should cross Tenant replication be enabled? Defaults to true. | `bool` | `true` | no |
| custom\_domain\_name | The Custom Domain Name to use for the Storage Account, which will be validated by Azure. | `string` | `null` | no |
| datastorages | n/a | `list(string)` | <pre>[<br>  "blob",<br>  "queue",<br>  "table",<br>  "file"<br>]</pre> | no |
| default\_to\_oauth\_authentication | Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account. The default value is false | `bool` | `false` | no |
| diff\_sub | The name of the addon vnet | `bool` | `false` | no |
| edge\_zone | Specifies the Edge Zone within the Azure Region where this Storage Account should exist. | `string` | `null` | no |
| enable\_advanced\_threat\_protection | Boolean flag which controls if advanced threat protection is enabled. | `bool` | `true` | no |
| enable\_diagnostic | Set to false to prevent the module from creating the diagnosys setting for the NSG Resource.. | `bool` | `false` | no |
| enable\_file\_share\_cors\_rules | Whether or not enable file share cors rules. | `bool` | `false` | no |
| enable\_hour\_metrics | Enable or disable the creation of the hour\_metrics block. | `bool` | `false` | no |
| enable\_https\_traffic\_only | Boolean flag which forces HTTPS if enabled, see here for more information. | `bool` | `true` | no |
| enable\_minute\_metrics | Enable or disable the creation of the minute\_metrics block. | `bool` | `false` | no |
| enable\_private\_endpoint | enable or disable private endpoint to storage account | `bool` | `true` | no |
| enable\_private\_link\_access | Enable or disable the creation of the private\_link\_access. | `bool` | `false` | no |
| enable\_routing | Enable or disable the creation of the routing block. | `bool` | `false` | no |
| enable\_sas\_policy | Enable or disable the creation of the sas\_policy block. | `bool` | `false` | no |
| enabled | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| eventhub\_authorization\_rule\_id | Eventhub authorization rule id to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| eventhub\_name | Eventhub Name to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| existing\_private\_dns\_zone | Name of the existing private DNS zone | `string` | `null` | no |
| existing\_private\_dns\_zone\_resource\_group\_name | The name of the existing resource group | `string` | `null` | no |
| expiration\_date | Expiration UTC datetime (Y-m-d'T'H:M:S'Z') | `string` | `"2034-10-22T18:29:59Z"` | no |
| extra\_tags | Variable to pass extra tags. | `map(string)` | `null` | no |
| file\_share\_authentication | Storage Account file shares authentication configuration. | <pre>object({<br>    directory_type = string<br>    active_directory = optional(object({<br>      storage_sid         = string<br>      domain_name         = string<br>      domain_sid          = string<br>      domain_guid         = string<br>      forest_name         = string<br>      netbios_domain_name = string<br>    }))<br>  })</pre> | `null` | no |
| file\_share\_cors\_rules | Storage Account file shares CORS rule. Please refer to the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#cors_rule) for more information. | <pre>list(object({<br>    allowed_headers    = list(string)<br>    allowed_methods    = list(string)<br>    allowed_origins    = list(string)<br>    exposed_headers    = list(string)<br>    max_age_in_seconds = number<br>  }))</pre> | `null` | no |
| file\_share\_properties\_smb | Storage Account file shares smb properties. | <pre>object({<br>    versions                        = optional(list(string))<br>    authentication_types            = optional(list(string))<br>    kerberos_ticket_encryption_type = optional(list(string))<br>    channel_encryption_type         = optional(list(string))<br>    multichannel_enabled            = optional(bool)<br>  })</pre> | `null` | no |
| file\_share\_retention\_policy\_in\_days | Storage Account file shares retention policy in days. Enabling this may require additional directory permissions. | `number` | `null` | no |
| file\_shares | List of containers to create and their access levels. | `list(object({ name = string, quota = number }))` | `[]` | no |
| hour\_metrics | n/a | <pre>object({<br>    enabled               = bool<br>    version               = string<br>    include_apis          = bool<br>    retention_policy_days = number<br>  })</pre> | <pre>{<br>  "enabled": false,<br>  "include_apis": false,<br>  "retention_policy_days": 7,<br>  "version": ""<br>}</pre> | no |
| identity\_type | Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both). | `string` | `"UserAssigned"` | no |
| infrastructure\_encryption\_enabled | Is infrastructure encryption enabled? Changing this forces a new resource to be created. Defaults to false. | `bool` | `true` | no |
| is\_hns\_enabled | Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2. Changing this forces a new resource to be created. | `bool` | `false` | no |
| key\_vault\_id | n/a | `string` | `""` | no |
| key\_vault\_rbac\_auth\_enabled | Is key vault has role base access enable or not. | `bool` | `true` | no |
| label\_order | Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] . | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| large\_file\_share\_enabled | Is Large File Share Enabled? | `bool` | `false` | no |
| location | The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table' | `string` | `"North Europe"` | no |
| log\_analytics\_destination\_type | Possible values are AzureDiagnostics and Dedicated, default to AzureDiagnostics. When set to Dedicated, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy AzureDiagnostics table. | `string` | `"AzureDiagnostics"` | no |
| log\_analytics\_workspace\_id | log analytics workspace id to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| logs | n/a | `list(string)` | <pre>[<br>  "StorageWrite",<br>  "StorageRead",<br>  "StorageDelete"<br>]</pre> | no |
| managedby | ManagedBy, eg 'Identos'. | `string` | `""` | no |
| management\_policy | Configure Azure Storage firewalls and virtual networks | <pre>list(object({<br>    prefix_match               = set(string)<br>    tier_to_cool_after_days    = number<br>    tier_to_archive_after_days = number<br>    delete_after_days          = number<br>    snapshot_delete_after_days = number<br>  }))</pre> | <pre>[<br>  {<br>    "delete_after_days": 100,<br>    "prefix_match": null,<br>    "snapshot_delete_after_days": 30,<br>    "tier_to_archive_after_days": 50,<br>    "tier_to_cool_after_days": 0<br>  }<br>]</pre> | no |
| management\_policy\_enable | n/a | `bool` | `false` | no |
| metrics | n/a | `list(string)` | <pre>[<br>  "Transaction",<br>  "Capacity"<br>]</pre> | no |
| metrics\_enabled | n/a | `list(bool)` | <pre>[<br>  true,<br>  true<br>]</pre> | no |
| min\_tls\_version | The minimum supported TLS version for the storage account | `string` | `"TLS1_2"` | no |
| minute\_metrics | n/a | <pre>list(object({<br>    enabled               = bool<br>    version               = string<br>    include_apis          = bool<br>    retention_policy_days = number<br>  }))</pre> | <pre>[<br>  {<br>    "enabled": false,<br>    "include_apis": false,<br>    "retention_policy_days": 7,<br>    "version": ""<br>  }<br>]</pre> | no |
| multi\_sub\_vnet\_link | Flag to control creation of vnet link for dns zone in different subscription | `bool` | `false` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| network\_rules | List of objects that represent the configuration of each network rules. | `map(string)` | `{}` | no |
| nfsv3\_enabled | Is NFSv3 protocol enabled? Changing this forces a new resource to be created. | `bool` | `false` | no |
| private\_link\_access | List of Privatelink objects to allow access from. | <pre>list(object({<br>    endpoint_resource_id = string<br>    endpoint_tenant_id   = string<br>  }))</pre> | `[]` | no |
| public\_network\_access\_enabled | Whether the public network access is enabled? Defaults to true. | `bool` | `true` | no |
| queue\_encryption\_key\_type | The encryption type of the queue service. Possible values are 'Service' and 'Account'. | `string` | `"Account"` | no |
| queue\_properties\_logging | Logging queue properties | <pre>object({<br>    delete                = optional(bool)<br>    read                  = optional(bool)<br>    write                 = optional(bool)<br>    version               = optional(string)<br>    retention_policy_days = optional(number)<br>  })</pre> | <pre>{<br>  "delete": true,<br>  "read": true,<br>  "retention_policy_days": 7,<br>  "version": "1.0",<br>  "write": true<br>}</pre> | no |
| queues | List of storages queues | `list(string)` | `[]` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-azure-storage.git"` | no |
| resource\_group\_name | A container that holds related resources for an Azure solution | `string` | `""` | no |
| restore\_policy | Wheteher or not create restore policy | `bool` | `false` | no |
| rotation\_policy | n/a | <pre>map(object({<br>    time_before_expiry   = string<br>    expire_after         = string<br>    notify_before_expiry = string<br>  }))</pre> | `null` | no |
| rotation\_policy\_enabled | Whether or not to enable rotation policy | `bool` | `false` | no |
| routing | n/a | <pre>list(object({<br>    publish_internet_endpoints  = bool<br>    publish_microsoft_endpoints = bool<br>    choice                      = string<br>  }))</pre> | <pre>[<br>  {<br>    "choice": "MicrosoftRouting",<br>    "publish_internet_endpoints": false,<br>    "publish_microsoft_endpoints": false<br>  }<br>]</pre> | no |
| sas\_policy\_settings | n/a | <pre>list(object({<br>    expiration_period = string<br>    expiration_action = string<br>  }))</pre> | <pre>[<br>  {<br>    "expiration_action": "Log",<br>    "expiration_period": "7.00:00:00"<br>  }<br>]</pre> | no |
| sftp\_enabled | Boolean, enable SFTP for the storage account | `bool` | `false` | no |
| shared\_access\_key\_enabled | Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). The default value is true. | `bool` | `true` | no |
| static\_website\_config | Static website configuration. Can only be set when the `account_kind` is set to `StorageV2` or `BlockBlobStorage`. | <pre>object({<br>    index_document     = optional(string)<br>    error_404_document = optional(string)<br>  })</pre> | `null` | no |
| storage\_account\_id | Storage account id to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| storage\_account\_name | The name of the azure storage account | `string` | `""` | no |
| storage\_blob\_cors\_rule | Storage Account blob CORS rule. Please refer to the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#cors_rule) for more information. | <pre>object({<br>    allowed_headers    = list(string)<br>    allowed_methods    = list(string)<br>    allowed_origins    = list(string)<br>    exposed_headers    = list(string)<br>    max_age_in_seconds = number<br>  })</pre> | `null` | no |
| storage\_blob\_data\_protection | Storage account blob Data protection parameters. | <pre>object({<br>    change_feed_enabled                       = optional(bool, false)<br>    versioning_enabled                        = optional(bool, false)<br>    last_access_time_enabled                  = optional(bool, false)<br>    delete_retention_policy_in_days           = optional(number, 0)<br>    container_delete_retention_policy_in_days = optional(number, 0)<br>    container_point_in_time_restore           = optional(bool, false)<br>  })</pre> | <pre>{<br>  "change_feed_enabled": false,<br>  "container_delete_retention_policy_in_days": 7,<br>  "delete_retention_policy_in_days": 7,<br>  "last_access_time_enabled": false,<br>  "versioning_enabled": false<br>}</pre> | no |
| subnet\_id | The resource ID of the subnet | `string` | `""` | no |
| table\_encryption\_key\_type | The encryption type of the table service. Possible values are 'Service' and 'Account'. | `string` | `"Account"` | no |
| tables | List of storage tables. | `list(string)` | `[]` | no |
| use\_subdomain | Should the Custom Domain Name be validated by using indirect CNAME validation? | `bool` | `false` | no |
| virtual\_network\_id | The name of the virtual network | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| containers | Map of containers. |
| file\_shares | Map of Storage SMB file shares. |
| queues | Map of Storage SMB file shares. |
| storage\_account\_id | The ID of the storage account. |
| storage\_account\_name | The name of the storage account. |
| storage\_account\_primary\_blob\_endpoint | The endpoint URL for blob storage in the primary location. |
| storage\_account\_primary\_location | The primary location of the storage account |
| storage\_account\_primary\_web\_endpoint | The endpoint URL for web storage in the primary location. |
| storage\_account\_primary\_web\_host | The hostname with port if applicable for web storage in the primary location. |
| storage\_primary\_access\_key | The primary access key for the storage account |
| storage\_primary\_connection\_string | The primary connection string for the storage account |
| tables | Map of Storage SMB file shares. |
