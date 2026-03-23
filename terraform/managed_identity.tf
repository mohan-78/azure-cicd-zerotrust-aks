# ─────────────────────────────────────────
# managed_identity.tf
# Creates Managed Identity for AKS pods
# Pods use this identity to authenticate
# to Azure services like Key Vault
# No passwords needed! Zero Trust!
# ─────────────────────────────────────────

# ─────────────────────────────────────────
# USER ASSIGNED MANAGED IDENTITY
# This is the identity our Flask pod uses
# Think of it as the pod's ID card
# ─────────────────────────────────────────
resource "azurerm_user_assigned_identity" "pod_identity" {
  name                = "id-cicd-poc-dev"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# ─────────────────────────────────────────
# KEY VAULT ACCESS POLICY FOR POD
# Gives the pod's identity permission
# to READ secrets from Key Vault
# Get = read secret value
# List = see secret names
# That's all pod needs!
# Least privilege principle!
# ─────────────────────────────────────────
resource "azurerm_key_vault_access_policy" "pod_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.pod_identity.principal_id

  # Pod can only GET and LIST secrets
  # Cannot create or delete secrets!
  # Least privilege = Zero Trust!
  secret_permissions = [
    "Get",
    "List"
  ]
}

# ─────────────────────────────────────────
# FEDERATED IDENTITY CREDENTIAL
# This connects the Managed Identity
# to our specific K8s Service Account
# 
# How it works:
# Pod runs with K8s Service Account
# K8s Service Account is linked to
# Azure Managed Identity via federation
# Pod gets Azure token automatically!
# No secrets mounted in pod! Zero Trust!
# ─────────────────────────────────────────
resource "azurerm_federated_identity_credential" "pod_federated" {
  name                = "fed-cicd-poc-dev"
  resource_group_name = azurerm_resource_group.rg.name
  parent_id           = azurerm_user_assigned_identity.pod_identity.id

  # AKS OIDC issuer URL
  # AKS uses this to issue tokens to pods
  # Enabled in aks.tf:
  # oidc_issuer_enabled = true
  issuer = azurerm_kubernetes_cluster.aks.oidc_issuer_url

  # K8s namespace where pod runs
  # default = standard namespace
  subject = "system:serviceaccount:default:flask-service-account"

  # Azure AD audience
  # This is always the same value
  # for Azure Workload Identity
  audience = ["api://AzureADTokenExchange"]
}