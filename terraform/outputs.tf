# ─────────────────────────────────────────
# outputs.tf
# Values exported after terraform apply
# Pipeline uses these in next stages
# ─────────────────────────────────────────

# ─────────────────────────────────────────
# RESOURCE GROUP
# ─────────────────────────────────────────
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  description = "Name of the Storage Account for Terraform state"
  value       = azurerm_storage_account.tfstate.name
}

# ─────────────────────────────────────────
# ACR OUTPUTS
# Pipeline uses login_server to
# tag and push Docker images
# ─────────────────────────────────────────
output "acr_name" {
  description = "Name of Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "ACR login server URL"
  value       = azurerm_container_registry.acr.login_server
}

# ─────────────────────────────────────────
# AKS OUTPUTS
# Pipeline uses cluster name to
# connect kubectl and deploy app
# ─────────────────────────────────────────
output "aks_cluster_name" {
  description = "Name of AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_kube_config" {
  description = "Kubeconfig to connect to AKS"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

# ─────────────────────────────────────────
# KEY VAULT OUTPUTS
# Flask app uses vault_uri to
# connect and read secrets
# ─────────────────────────────────────────
output "key_vault_name" {
  description = "Name of Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "Key Vault URI for app to connect"
  value       = azurerm_key_vault.kv.vault_uri
}

# ─────────────────────────────────────────
# MANAGED IDENTITY OUTPUTS
# K8s manifest uses client_id to
# annotate the Service Account
# ─────────────────────────────────────────
output "managed_identity_client_id" {
  description = "Client ID of Managed Identity"
  value       = azurerm_user_assigned_identity.pod_identity.client_id
}

output "managed_identity_name" {
  description = "Name of Managed Identity"
  value       = azurerm_user_assigned_identity.pod_identity.name
}

# ─────────────────────────────────────────
# OIDC ISSUER
# Used when setting up Workload Identity
# ─────────────────────────────────────────
output "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL"
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}