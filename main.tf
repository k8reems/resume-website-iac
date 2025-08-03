# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "resume_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "Resume Website"
  }
}

# Create a storage account
resource "azurerm_storage_account" "resume_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.resume_rg.name
  location                 = azurerm_resource_group.resume_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  static_website {
    index_document     = "index.html"
    error_404_document = "404.html"
  }

  tags = {
    Environment = var.environment
    Project     = "Resume Website"
  }
}

# Optional: Create Azure Front Door Profile (Standard tier)
resource "azurerm_cdn_frontdoor_profile" "resume_cdn" {
  count               = var.enable_cdn ? 1 : 0
  name                = "${var.project_name}-frontdoor"
  resource_group_name = azurerm_resource_group.resume_rg.name
  sku_name            = "Standard_AzureFrontDoor"

  tags = {
    Environment = var.environment
    Project     = "Resume Website"
  }
}

# Optional: Create Front Door Endpoint
resource "azurerm_cdn_frontdoor_endpoint" "resume_cdn_endpoint" {
  count                    = var.enable_cdn ? 1 : 0
  name                     = "${var.project_name}-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.resume_cdn[0].id

  tags = {
    Environment = var.environment
    Project     = "Resume Website"
  }
}

# Optional: Create Front Door Origin Group
resource "azurerm_cdn_frontdoor_origin_group" "resume_origin_group" {
  count                    = var.enable_cdn ? 1 : 0
  name                     = "${var.project_name}-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.resume_cdn[0].id

  load_balancing {
    additional_latency_in_milliseconds = 50
    sample_size                        = 4
    successful_samples_required        = 3
  }

  health_probe {
    interval_in_seconds = 240
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
  }
}

# Optional: Create Front Door Origin
resource "azurerm_cdn_frontdoor_origin" "resume_origin" {
  count                         = var.enable_cdn ? 1 : 0
  name                          = "${var.project_name}-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.resume_origin_group[0].id

  enabled                        = true
  host_name                      = azurerm_storage_account.resume_storage.primary_web_host
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = azurerm_storage_account.resume_storage.primary_web_host
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true
}

# Optional: Create Front Door Route
resource "azurerm_cdn_frontdoor_route" "resume_route" {
  count                         = var.enable_cdn ? 1 : 0
  name                          = "${var.project_name}-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.resume_cdn_endpoint[0].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.resume_origin_group[0].id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.resume_origin[0].id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = true
}
