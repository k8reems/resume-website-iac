output "website_url" {
  description = "URL of the static website"
  value       = azurerm_storage_account.resume_storage.primary_web_endpoint
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.resume_storage.name
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.resume_rg.name
}

output "cdn_endpoint_url" {
  description = "Front Door endpoint URL (if enabled)"
  value       = var.enable_cdn ? "https://${azurerm_cdn_frontdoor_endpoint.resume_cdn_endpoint[0].host_name}" : "CDN not enabled"
}

output "frontdoor_profile_name" {
  description = "Name of the Front Door profile (if enabled)"
  value       = var.enable_cdn ? azurerm_cdn_frontdoor_profile.resume_cdn[0].name : "CDN not enabled"
}

output "frontdoor_endpoint_fqdn" {
  description = "FQDN of the Front Door endpoint (if enabled)"
  value       = var.enable_cdn ? azurerm_cdn_frontdoor_endpoint.resume_cdn_endpoint[0].host_name : "CDN not enabled"
}

output "storage_account_primary_access_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.resume_storage.primary_access_key
  sensitive   = true
}
