# ─────────────────────────────────────────
# aks.tf
# Azure Kubernetes Service cluster
# This is where our Flask app runs
# ─────────────────────────────────────────

resource "azurerm_kubernetes_cluster" "aks" {

  # Cluster name and location
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # DNS prefix for the cluster
  # Used in the cluster API URL
  dns_prefix = "aks-cicd-poc"

  # ─────────────────────────────────────
  # DEFAULT NODE POOL
  # These are the VMs that run our pods
  # ─────────────────────────────────────
  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = var.aks_node_size

    # OS disk size in GB
    # 30GB is enough for POC
    os_disk_size_gb = 30
  }

  # ─────────────────────────────────────
  # IDENTITY
  # AKS uses SystemAssigned identity
  # to manage its own resources
  # like Load Balancer, Public IP
  # No Service Principal needed!
  # Zero Trust principle!
  # ─────────────────────────────────────
  identity {
    type = "SystemAssigned"
  }

  # ─────────────────────────────────────
  # NETWORK PROFILE
  # How pods communicate with each other
  # and with the outside world
  # ─────────────────────────────────────
  network_profile {
    network_plugin = "kubenet"
    dns_service_ip = "10.0.0.10"
    service_cidr   = "10.0.0.0/16"
  }

  # ─────────────────────────────────────
  # OIDC ISSUER
  # Enables Workload Identity Federation
  # Pods use this to authenticate to
  # Azure services like Key Vault
  # No passwords in pods!
  # Zero Trust security!
  # ─────────────────────────────────────
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  tags = var.tags
}

# ─────────────────────────────────────────
# ROLE ASSIGNMENT — AKS pulls from ACR
# Gives AKS permission to pull
# Docker images from our ACR
# Without this AKS cannot pull images!
# Uses Managed Identity — no passwords!
# ─────────────────────────────────────────
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

