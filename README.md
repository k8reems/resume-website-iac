# Resume Website Infrastructure

This repository contains the Terraform Infrastructure as Code (IaC) for deploying a professional resume website on Azure with Azure Front Door Standard tier CDN.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Azure Front   │    │  Azure Storage   │    │  Static Website │
│   Door (CDN)    │───▶│    Account       │───▶│     Content     │
│  Standard Tier  │    │ (Static Website) │    │ (HTML/CSS/JS)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
        │
        ▼
┌─────────────────┐
│  Global Edge    │
│   Locations     │
│ (Performance &  │
│   Caching)      │
└─────────────────┘
```

## 📁 Infrastructure Components

### Core Resources
- **Azure Resource Group**: Container for all resources
- **Azure Storage Account**: Hosts static website files with `$web` container
- **Azure Front Door Profile**: Standard tier CDN with global edge locations
- **Front Door Endpoint**: CDN endpoint for content delivery
- **Origin Group**: Load balancing and health probe configuration
- **Origin**: Points to Azure Storage static website
- **Route**: Traffic routing with HTTPS enforcement

### Features
- 🌐 **Global CDN**: Azure Front Door with worldwide edge locations
- 🔒 **HTTPS Enforcement**: Automatic HTTP to HTTPS redirect
- 🏥 **Health Monitoring**: Automatic health probes every 240 seconds
- ⚖️ **Load Balancing**: Latency-based traffic distribution
- 📊 **Performance Optimization**: Advanced caching and compression
- 🛡️ **Security**: Certificate validation and secure origins

## 🚀 Quick Start

### Prerequisites

- Azure CLI installed and configured
- Terraform >= 1.0 installed
- Azure subscription with sufficient permissions
- Globally unique storage account name

### 1. Clone and Setup

```bash
git clone <repository-url>
cd resume-webapp-infra
```

### 2. Configure Variables

Create or update `terraform.tfvars`:

```hcl
# Required: Update with your unique values
resource_group_name   = "rg-resume-website"
location             = "East US"
storage_account_name = "stresumewebYOURNAME"  # Must be globally unique!
project_name         = "resume-website"
environment          = "production"
enable_cdn           = true                   # Set to false to disable CDN
custom_domain        = ""                     # Optional: your custom domain
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Deploy infrastructure
terraform apply
```

### 4. Verify Deployment

After successful deployment, you'll see outputs including:
- `website_url`: Direct Azure Storage static website URL
- `cdn_endpoint_url`: Front Door CDN endpoint URL (recommended)
- `frontdoor_profile_name`: Name of the Front Door profile

## 📋 Terraform Resources

### Resource Group
```hcl
resource "azurerm_resource_group" "resume_rg" {
  name     = var.resource_group_name
  location = var.location
}
```

### Storage Account (Static Website)
```hcl
resource "azurerm_storage_account" "resume_storage" {
  name                     = var.storage_account_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  
  static_website {
    index_document     = "index.html"
    error_404_document = "404.html"
  }
}
```

### Azure Front Door (Standard Tier)
```hcl
resource "azurerm_cdn_frontdoor_profile" "resume_cdn" {
  name                = "${var.project_name}-frontdoor"
  resource_group_name = azurerm_resource_group.resume_rg.name
  sku_name            = "Standard_AzureFrontDoor"
}
```

## 🔧 Configuration Options

### Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | string | `"rg-resume-website"` | Azure Resource Group name |
| `location` | string | `"East US"` | Azure region for deployment |
| `storage_account_name` | string | `"stresumeweb001"` | Storage account name (must be globally unique) |
| `project_name` | string | `"resume-website"` | Project name used for resource naming |
| `environment` | string | `"production"` | Environment tag |
| `enable_cdn` | bool | `false` | Enable/disable Azure Front Door CDN |
| `custom_domain` | string | `""` | Custom domain name (optional) |

### Outputs

| Output | Description |
|--------|-------------|
| `website_url` | Direct Azure Storage static website URL |
| `storage_account_name` | Name of the created storage account |
| `resource_group_name` | Name of the resource group |
| `cdn_endpoint_url` | Front Door CDN endpoint URL |
| `frontdoor_profile_name` | Name of the Front Door profile |
| `frontdoor_endpoint_fqdn` | FQDN of the Front Door endpoint |
| `storage_account_primary_access_key` | Storage account access key (sensitive) |

## 🌐 CDN Configuration Details

### Front Door Standard Tier Features

#### Health Probes
```hcl
health_probe {
  interval_in_seconds = 240        # Check every 4 minutes
  path                = "/"        # Health check path
  protocol            = "Https"    # Use HTTPS for health checks
  request_type        = "HEAD"     # HTTP HEAD request
}
```

#### Load Balancing
```hcl
load_balancing {
  additional_latency_in_milliseconds = 50  # Latency threshold
  sample_size                        = 4   # Number of samples
  successful_samples_required        = 3   # Required successful samples
}
```

#### Route Configuration
```hcl
supported_protocols    = ["Http", "Https"]  # Support both protocols
patterns_to_match      = ["/*"]             # Match all paths
forwarding_protocol    = "HttpsOnly"        # Forward only HTTPS
https_redirect_enabled = true               # Redirect HTTP to HTTPS
```

## 🔒 Security Features

### HTTPS Enforcement
- Automatic HTTP to HTTPS redirect
- HTTPS-only forwarding to origin
- Certificate name checking enabled

### Origin Security
- Origin host header validation
- Certificate name check enabled
- Secure communication with storage account

## 📊 Cost Optimization

### Storage Account
- **Tier**: Standard (cost-effective for static websites)
- **Replication**: LRS (Locally Redundant Storage)
- **Kind**: StorageV2 (latest generation)

### Front Door Standard Tier
- **Pay-per-use**: Cost based on data transfer and requests
- **No minimum commitment**: Scale up/down as needed
- **Regional optimization**: Automatically uses closest edge location

## 🛠️ Management Commands

### Infrastructure Management
```bash
# View current state
terraform show

# Plan changes
terraform plan

# Apply changes
terraform apply

# Refresh state
terraform refresh

# Destroy infrastructure (careful!)
terraform destroy
```

### Azure CLI Integration
```bash
# List storage accounts
az storage account list --resource-group rg-resume-website

# Check Front Door status
az cdn profile list --resource-group rg-resume-website

# View storage account static website configuration
az storage blob service-properties show --account-name <storage-account-name>
```

## 🔍 Troubleshooting

### Common Issues

#### Storage Account Name Not Available
```
Error: storage account name is not available
```
**Solution**: Update `storage_account_name` in `terraform.tfvars` to a globally unique name.

#### Insufficient Permissions
```
Error: authorization failed
```
**Solution**: Ensure your Azure account has Contributor role on the subscription or resource group.

#### Front Door Deployment Issues
```
Error: Front Door profile creation failed
```
**Solution**: Check if Front Door is available in your selected region and verify subscription limits.

### Verification Steps

1. **Check Resource Group**:
   ```bash
   az group show --name rg-resume-website
   ```

2. **Verify Storage Account**:
   ```bash
   az storage account show --name <storage-account-name> --resource-group rg-resume-website
   ```

3. **Test Website Accessibility**:
   ```bash
   curl -I https://<storage-account-name>.z13.web.core.windows.net/
   ```

4. **Check Front Door Status**:
   ```bash
   az cdn profile show --name <frontdoor-profile-name> --resource-group rg-resume-website
   ```

## 📈 Monitoring and Maintenance

### Terraform State Management
- State file is stored locally by default
- Consider using remote state for production (Azure Storage, Terraform Cloud)
- Regular state backups recommended

### Infrastructure Updates
```bash
# Check for provider updates
terraform init -upgrade

# Validate configuration
terraform validate

# Plan updates
terraform plan

# Apply updates
terraform apply
```

## 🚀 Advanced Configuration

### Custom Domain Setup

1. **Add CNAME record** pointing to Front Door endpoint
2. **Update terraform.tfvars**:
   ```hcl
   custom_domain = "resume.yourdomain.com"
   ```
3. **Add custom domain resource** to `main.tf`

### WAF Integration

Add Web Application Firewall for enhanced security:
```hcl
resource "azurerm_cdn_frontdoor_firewall_policy" "resume_waf" {
  name                = "${var.project_name}-waf"
  resource_group_name = azurerm_resource_group.resume_rg.name
  sku_name            = "Standard_AzureFrontDoor"
  enabled             = true
  mode                = "Prevention"
}
```

## 📚 Additional Resources

- [Azure Front Door Documentation](https://docs.microsoft.com/en-us/azure/frontdoor/)
- [Azure Storage Static Website](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the configuration
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Infrastructure Status**: ✅ **Production Ready**

This infrastructure supports a professional resume website with global CDN, automatic HTTPS, and enterprise-grade performance and security features.
