# ─────────────────────────────────────────
# variables.tf
# All input variables for our POC
# ─────────────────────────────────────────

# What environment are we deploying?
# dev = development, prod = production
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# Which Azure region?
# East US = cheapest + closest
variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

# Resource Group name
# All resources live inside this
variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-cicd-poc-dev"
}

# ACR name — must be globally unique
# Only letters and numbers, no dashes
variable "acr_name" {
  description = "Azure Container Registry name"
  type        = string
  default     = "acrcicdpocdev"
}

# AKS cluster name
variable "aks_cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "aks-cicd-poc-dev"
}

# VM size for AKS nodes
# Standard_B2s = 2 CPU, 4GB RAM
# Cheapest option for POC
variable "aks_node_size" {
  description = "AKS node VM size"
  type        = string
  default     = "Standard_DC2s_v3"
}

# How many nodes in AKS?
# 1 is enough for POC
variable "aks_node_count" {
  description = "Number of AKS nodes"
  type        = number
  default     = 1
}

# Key Vault name — must be globally unique
# 3-24 characters, letters numbers dashes
variable "key_vault_name" {
  description = "Key Vault name"
  type        = string
  default     = "kv-cicd-poc-dev"
}

# Storage account for Terraform state
# Must be globally unique, lowercase only


# Tags — org best practice
# Always tag resources for cost tracking
variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {
    environment = "dev"
    project     = "cicd-poc"
    owner       = "sk-devops"
    managed_by  = "terraform"
  }
}

    