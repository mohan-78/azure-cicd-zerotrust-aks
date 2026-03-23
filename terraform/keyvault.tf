# ─────────────────────────────────────────
# keyvault.tf
# Azure Key Vault
# Stores secrets securely
# App reads secrets at runtime
# No passwords in code!
# ─────────────────────────────────────────

resource "azurerm_key_vault" "kv" {

  # Key Vault name — globally unique
  name                = var.key_vault_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Your Azure Tenant ID
  # Read automatically from az login
  # No hardcoding!
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # SKU — standard is enough for POC
  # premium adds HSM hardware security
  sku_name            = "standard"

  # ─────────────────────────────────────
  # SOFT DELETE
  # If Key Vault deleted accidentally
  # it stays recoverable for 7 days
  # Protects against accidental deletion
  # ─────────────────────────────────────
  soft_delete_retention_days = 7

  # ─────────────────────────────────────
  # PURGE PROTECTION
  # Even after soft delete —
  # nobody can permanently delete
  # during retention period
  # Extra safety layer!
  # ─────────────────────────────────────
  purge_protection_enabled = false

  # ─────────────────────────────────────
  # ACCESS POLICY FOR YOU (DevOps)
  # Gives YOUR account full access
  # to manage secrets in Key Vault
  # You need this to add secrets!
  # ─────────────────────────────────────
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    # What YOU can do with secrets
    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge",
      "Recover"
    ]

    # What YOU can do with keys
    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Purge"
    ]
  }

  tags = var.tags
}

# ─────────────────────────────────────────
# SAMPLE SECRET
# Adding a test secret to Key Vault
# Our Flask app will read this!
# In real org — DB passwords, API keys
# would be stored here
# ─────────────────────────────────────────
resource "azurerm_key_vault_secret" "app_secret" {

  # Secret name — app uses this name
  # to look up the secret
  name         = "app-secret-value"

  # Secret value — what app reads
  # In real org this would be
  # an actual password or API key
  value        = "HelloFromKeyVault-POC-2024"

  # Which Key Vault to store in
  key_vault_id = azurerm_key_vault.kv.id

  # Depends on Key Vault being ready
  depends_on = [azurerm_key_vault.kv]
}

