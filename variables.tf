variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-resume-website"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  description = "Name of the Azure Storage Account (must be globally unique)"
  type        = string
  default     = "stresumeweb001"
}

variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
  default     = "resume-website"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "production"
}

variable "enable_cdn" {
  description = "Enable Azure CDN for the website"
  type        = bool
  default     = false
}

variable "custom_domain" {
  description = "Custom domain name for the website (optional)"
  type        = string
  default     = ""
}
