# ─────────────────────────────────────────
# main.tf
# Provider configuration + Resource Group
# + Storage Account for Terraform state
# ─────────────────────────────────────────

# ─────────────────────────────────────────
# TERRAFORM BLOCK
# Tells Terraform which version to use
# and which plugins to download
# ─────────────────────────────────────────
terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Block 2 — provider block (SEPARATE!)
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# ─────────────────────────────────────────
# PROVIDER BLOCK
# Tells Terraform to talk to Azure
# Uses your az login credentials
# No passwords needed here!
# ─────────────────────────────────────────


# ─────────────────────────────────────────
# DATA BLOCK
# Reads your current Azure login info
# Gets your Tenant ID and Subscription ID
# automatically — no hardcoding!
# ─────────────────────────────────────────
data "azurerm_client_config" "current" {}

# ─────────────────────────────────────────
# RESOURCE GROUP
# Container for ALL our resources
# Everything we create goes inside this
# ─────────────────────────────────────────
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ─────────────────────────────────────────
# STORAGE ACCOUNT
# Used to store Terraform state file
# remotely in Azure Blob Storage
# Pipeline and team share same state
# ─────────────────────────────────────────


# ─────────────────────────────────────────
# STORAGE CONTAINER
# Bucket inside Storage Account
# where tfstate file is stored
# ─────────────────────────────────────────


# ─────────────────────────────────────────
# AZURE CONTAINER REGISTRY (ACR)
# Private registry for Docker images
# Pipeline pushes images here
# AKS pulls images from here
# ─────────────────────────────────────────
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}



