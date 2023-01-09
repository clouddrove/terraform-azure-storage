output "storage_account_id" {
  value       = join("", azurerm_storage_account.storage.*.id)
  description = "The ID of the storage account."
}

output "storage_account_name" {
  value       = join("", azurerm_storage_account.storage.*.name)
  description = "The name of the storage account."
}

output "storage_account_primary_location" {
  value       = join("", azurerm_storage_account.storage.*.primary_location)
  description = "The primary location of the storage account"
}

output "storage_account_primary_web_endpoint" {
  value       = join("", azurerm_storage_account.storage.*.primary_web_endpoint)
  description = "The endpoint URL for web storage in the primary location."
}

output "storage_account_primary_web_host" {
  value       = join("", azurerm_storage_account.storage.*.primary_web_host)
  description = "The hostname with port if applicable for web storage in the primary location."
}

output "storage_primary_connection_string" {
  value       = join("", azurerm_storage_account.storage.*.primary_connection_string)
  sensitive   = true
  description = "The primary connection string for the storage account"
}

output "storage_primary_access_key" {
  value       = join("", azurerm_storage_account.storage.*.primary_access_key)
  sensitive   = true
  description = "The primary access key for the storage account"
}

output "storage_secondary_access_key" {
  value       = join("", azurerm_storage_account.storage.*.secondary_access_key)
  sensitive   = true
  description = "The primary access key for the storage account."
}

output "containers" {
  value       = { for c in azurerm_storage_container.container : c.name => c.id }
  description = "Map of containers."
}

output "file_shares" {
  description = "Map of Storage SMB file shares."
  value       = { for f in azurerm_storage_share.fileshare : f.name => f.id }
}

output "tables" {
  description = "Map of Storage SMB file shares."
  value       = { for t in azurerm_storage_table.tables : t.name => t.id }
}

output "queues" {
  description = "Map of Storage SMB file shares."
  value       = { for q in azurerm_storage_queue.queues : q.name => q.id }
}